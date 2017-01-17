using JSON
import BigArrays: get_config_dict

export GSDict, get_config_dict

const DEFAULT_CREDENTIAL_FILENAME = "~/.google_credentials.json"
const DEFAULT_SESSION = GoogleSession(expanduser(DEFAULT_CREDENTIAL_FILENAME), ["devstorage.full_control"])
const DEFAULT_CONFIG_FILENAME = "config.json"

GSDict = KeyStore

function GSDict( bucketName::String )
    bucketName = replace(bucketName, "gs://", "")
    if bucketName[end]=="/"
        bucketName = bucketName[1:end-1]
    end
    @assert !contains(bucketName, "/")

    KeyStore{Symbol, Vector{UInt8}}(
        bucketName;                                  # Key-value store name. Created if it doesn't already exist.
        session     = DEFAULT_SESSION,
        val_writer  = serialize_to_uint8_vector,    # Function for serializing data before writing to the store
        val_reader  = deserialize_from_vector,      # Function for deserializing data before reading from the store
        use_remote  = true,                         # Defaults to true. Commit every write to the remote store.
        use_cache   = false,                         # Defaults to true. Commit every write to the local store.
        reset       = false,                         # Defaults to false. Empty the bucket if it exists.
        gzip        = false
    )
end

function get_config_dict( d::GSDict )
    str = gsread( "gs://$(d.bucket_name)/$(DEFAULT_CONFIG_FILENAME)" )
    JSON.parse( str, dicttype=Dict{Symbol, Any} )
end

function serialize_to_uint8_vector(x)
    io = IOBuffer()
    serialize(io, x)
    takebuf_array(io)
end

deserialize_from_vector(x) = deserialize(IOBuffer(x))
