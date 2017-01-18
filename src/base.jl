import BigArrays: get_config_dict

export GSDict, get_config_dict

const DEFAULT_CREDENTIAL_FILENAME = "~/.google_credentials.json"
# const DEFAULT_CREDENTIAL = GoogleCredentials(expanduser("~/credentials.json"))
const DEFAULT_SESSION = GoogleSession(expanduser(DEFAULT_CREDENTIAL_FILENAME), ["devstorage.full_control"])
const DEFAULT_CONFIG_FILENAME = "config.json"

immutable GSDict <: Associative
    kvStore     ::KeyStore
    bucketName  ::String
    keyPrefix   ::String
end

"""
    split gs path to bucket name and key
"""
function splitgs( path::String )
    path = replace(path, "gs://", "")
    bucketName, key = split(path, "/", limit=2)
    return String(bucketName), String(key)
end

function GSDict( path::String )
    bucketName, keyPrefix = splitgs(path)

    bucketName = replace(bucketName, "gs://", "")
    keyPrefix = keyPrefix[end]=="/" ? keyPrefix[1:end-1] : keyPrefix

    kvStore = KeyStore{String, Vector{UInt8}}(
        bucketName;                                  # Key-value store name. Created if it doesn't already exist.
        session     = DEFAULT_SESSION,
        val_writer  = serialize_to_uint8_vector,    # Function for serializing data before writing to the store
        val_reader  = deserialize_from_vector,      # Function for deserializing data before reading from the store
        use_remote  = true,                         # Defaults to true. Commit every write to the remote store.
        use_cache   = false,                         # Defaults to true. Commit every write to the local store.
        empty       = false,                         # Defaults to false. Empty the bucket if it exists.
        gzip        = false
    )
    GSDict( kvStore, bucketName, keyPrefix )
end

function Base.delete!( d::GSDict, key::String )
    delete!( d.kvStore, joinpath(d.keyPrefix, key) )
end

# function Base.reset!( d::GSDict )
#     reset!(d.kvStore)
# end

function Base.setindex!( d::GSDict, value::Any, key::String )
    d.kvStore[joinpath(d.keyPrefix, key)] = value
end

function Base.getindex( d::GSDict, key::String)
    d.kvStore[joinpath(d.keyPrefix, key)]
end

function Base.keys( d::GSDict )
    # keyList = keys( d.kvStore )
    # for i in eachindex(keyList)
    #     keyList[i] = joinpath(d.keyPrefix, keyList[i])
    # end
    # @show keyList
    ds = storage(:Object, :list, d.bucketName; prefix=d.keyPrefix, fields="items(name)")
    ret = Vector{String}()
    for i in eachindex(ds)
        if !contains( ds[i][:name], DEFAULT_CONFIG_FILENAME)
            ds[i][:name] = replace(ds[i][:name], "$(d.keyPrefix)/", "" )
            push!(ret, ds[i][:name])
        end
    end
    return ret
end

function get_config_dict( d::GSDict )
    # str = gsread( "gs://$(d.bucketName)/$(d.keyPrefix)/$(DEFAULT_CONFIG_FILENAME)" )
    storage(:Object, :get, d.bucketName,
                joinpath(d.keyPrefix, DEFAULT_CONFIG_FILENAME));
    # @show ret
    # @show joinpath(d.keyPrefix, DEFAULT_CONFIG_FILENAME)
    # @show d
    # # JSON.parse( str, dicttype=Dict{Symbol, Any} )
    # return ret
end

function serialize_to_uint8_vector(x)
    io = IOBuffer()
    serialize(io, x)
    takebuf_array(io)
end

deserialize_from_vector(x) = deserialize(IOBuffer(x))
