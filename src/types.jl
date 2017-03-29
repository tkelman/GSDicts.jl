export GSDict, GSDictsNDFormat, GSDictsNeuroglancerFormat

const DEFAULT_FORMAT = :ND
const DEFAULT_GZIP = false

immutable GSDict <: Associative
    kvStore     	::KeyStore
    bucketName  	::String
    keyPrefix   	::String
    googleSession	::GoogleCloud.session.GoogleSession
    configDict      ::Dict{Symbol, Any}
    # function (::Type{GSDict}){B}(
    #     kvStore     ::
    #     )
end

"""
    GSDict( path::String; gzip::Bool = DEFAULT_GZIP, format::Symbol = DEFAULT_FORMAT )
construct an associative datastructure based on Google Cloud Storage
format: :ND | :Neuroglancer
"""
function GSDict( path::String; gzip::Bool = DEFAULT_GZIP )
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

    # automatically choose backend based on the existance of "config.json" file
    if haskey(kvStore, "config.json")
        # this is a customized format dict
        println("this is a customized format dict supporting ND blocks")
        configDict = get_config_dict_from_ND(googleSession, bucketName, keyPrefix)
    elseif hasinfo(googleSession, bucketName, keyPrefix)
        println("this is a neuroglancer format dict, supporting neuroglancer blocks")
        configDict = get_config_dict_from_neuroglancer(googleSession, bucketName, keyPrefix)
    else
        println("did not find any specific configuration json file!")
        configDict = Dict{Symbol, Any}()
    end

    GSDict( kvStore, bucketName, keyPrefix, googleSession, configDict )
end
