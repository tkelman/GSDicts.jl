
function get_credential_filename()
    if isfile(expanduser("~/.google_credentials.json"))
        DEFAULT_CREDENTIAL_FILENAME = expanduser("~/.google_credentials.json")
    elseif isfile(joinpath(dirname(@__FILE__), "../.google_credentials.json"))
        DEFAULT_CREDENTIAL_FILENAME = joinpath(dirname(@__FILE__), "../.google_credentials.json")
    else
        error("credential file is not in default place!")
    end
    return DEFAULT_CREDENTIAL_FILENAME
end

export GSDict, GSDictsNDFormat, GSDictsNeuroglancerFormat

const DEFAULT_CREDENTIAL_FILENAME = get_credential_filename()
const DEFAULT_FORMAT = :ND
const DEFAULT_GZIP = true

immutable GSDict <: Associative
    kvStore     	::KeyStore
    bucketName  	::String
    keyPrefix   	::String
    googleSession	::GoogleCloud.session.GoogleSession
    configDict      ::Dict{Symbol, Any}
end

"""
    GSDict( path::String; gzip::Bool = DEFAULT_GZIP, format::Symbol = DEFAULT_FORMAT )
construct an associative datastructure based on Google Cloud Storage
format: :ND | :Neuroglancer
"""
function GSDict( path::String; gzip::Bool = DEFAULT_GZIP, credentialFileName = DEFAULT_CREDENTIAL_FILENAME )
    bucketName, keyPrefix = splitgs(path)
    bucketName = replace(bucketName, "gs://", "")
    keyPrefix = keyPrefix[end]=="/" ? keyPrefix[1:end-1] : keyPrefix

    googleSession = GoogleSession( credentialFileName, ["devstorage.full_control"])
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
