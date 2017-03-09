import BigArrays: get_config_dict

export GSDict, get_config_dict

const DEFAULT_CREDENTIAL_FILENAME = expanduser("~/.google_credentials.json")
# const DEFAULT_CREDENTIAL = GoogleCredentials(expanduser("~/credentials.json"))
const DEFAULT_GZIP = true
const DEFAULT_VALUE_FORMAT = :identity

immutable GSDict <: Associative
    kvStore     	::KeyStore
    bucketName  	::String
    keyPrefix   	::String
    googleSession	::GoogleCloud.session.GoogleSession
end

function GSDict( path::String; gzip = DEFAULT_GZIP )
    bucketName, keyPrefix = splitgs(path)

    bucketName = replace(bucketName, "gs://", "")
    keyPrefix = keyPrefix[end]=="/" ? keyPrefix[1:end-1] : keyPrefix

    googleSession = GoogleSession(expanduser(DEFAULT_CREDENTIAL_FILENAME), ["devstorage.full_control"])
    kvStore = KeyStore{String, Vector{UInt8}}(
        bucketName,             # Key-value store name. Created if it doesn't already exist.
        googleSession;
        key_format  = :string,
        val_format  = :identity,
        empty       = false,    # Defaults to false. Empty the bucket if it exists.
        gzip        = gzip
    )
    GSDict( kvStore, bucketName, keyPrefix, googleSession )
end

function Base.delete!( d::GSDict, key::String )
	authorize( d.googleSession )
    # authorize( d.kvStore.session )
    delete!( d.kvStore, joinpath(d.keyPrefix, key) )
end

function Base.setindex!( d::GSDict, value::Any, key::String )
	authorize( d.googleSession )
    # authorize( d.kvStore.session )
    d.kvStore[joinpath(d.keyPrefix, key)] = value
end

function Base.getindex( d::GSDict, key::String)
	authorize( d.googleSession )
    d.kvStore[joinpath(d.keyPrefix, key)]
end

function Base.keys( d::GSDict )
    # keyList = keys( d.kvStore )
    # for i in eachindex(keyList)
    #     keyList[i] = joinpath(d.keyPrefix, keyList[i])
    # end
    # @show keyList
	authorize(d.googleSession)
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
