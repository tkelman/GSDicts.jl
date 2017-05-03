
# map datatype of python to Julia
const DATATYPE_MAP = Dict{String, String}(
    "uint8"     => "UInt8",
    "uint16"    => "UInt16",
    "uint32"    => "UInt32",
    "uint64"    => "UInt64",
    "float32"   => "Float32",
    "float64"   => "Float64"
)

"""
    split gs path to bucket name and key
"""
function splitgs( path::String )
    path = replace(path, "gs://", "")
    bucketName, key = split(path, "/", limit=2)
    return String(bucketName), String(key)
end

function get_config_dict( d::GSDict )
    return d.configDict
end

function get_config_dict_from_ND(
    googleSession   ::GoogleCloud.session.GoogleSession,
    bucketName      ::String,
    keyPrefix       ::String)
    # str = gsread( "gs://$(bucketName)/$(d.keyPrefix)/$(DEFAULT_CONFIG_FILENAME)" )
	authorize(googleSession; cache=true)
    storage(:Object, :get, bucketName,
                joinpath(keyPrefix, "config.json"));
    # @show ret
    # @show joinpath(keyPrefix, DEFAULT_CONFIG_FILENAME)
    # @show d
    # # JSON.parse( str, dicttype=Dict{Symbol, Any} )
    # return ret
end

function getinfo(googleSession::GoogleCloud.session.GoogleSession,
            bucketName      ::String,
            keyPrefix       ::String)
    authorize(googleSession; cache=true)
    keyPrefix = rstrip(keyPrefix,'/')
    k = basename( keyPrefix )
    dir = dirname( keyPrefix )
    @show joinpath(bucketName, dir, "info")
    storage(:Object, :get, bucketName,
                        joinpath(dir, "info"))
end

function hasinfo(googleSession::GoogleCloud.session.GoogleSession,
            bucketName      ::String,
            keyPrefix       ::String)
    infoDict = getinfo( googleSession, bucketName, keyPrefix )
    @show infoDict
    return isa(infoDict, String) || isa(infoDict, Dict)
end

function get_config_dict_from_neuroglancer(
            googleSession   ::GoogleCloud.session.GoogleSession,
            bucketName      ::String,
            keyPrefix       ::String,
             )
    # str = gsread( "gs://$(bucketName)/$(keyPrefix)/$(DEFAULT_CONFIG_FILENAME)" )
	authorize(googleSession; cache=true)
    # configDict = storage(:Object, :get, bucketName,
    #                     joinpath(keyPrefix, configFileName));
    keyPrefix = rstrip(keyPrefix,'/')
    k = basename( keyPrefix )
    dir = dirname( keyPrefix )
    infoDict = storage(:Object, :get, bucketName,
                        joinpath(dir, "info"))
    @show infoDict
    # transform the key type to Symbol
    infoDict = key2symbol( infoDict )

    @show infoDict
    @show DATATYPE_MAP[ infoDict[:data_type] ]
    configDict = Dict{Symbol, Any}(
        :dataType => DATATYPE_MAP[ infoDict[:data_type] ]
    )
    for d in infoDict[:scales]
        if d[:key] == k
            if infoDict[:num_channels] == 1
                configDict[:chunkSize] = d[:chunk_sizes][1]
            else
                configDict[:chunkSize] = [d[:chunk_sizes][1]..., infoDict[:num_channels]]
            end
            configDict[:coding]     = d[:encoding]
            configDict[:totalSize]  = d[:size]
            configDict[:offset]     = d[:voxel_offset]
        end
    end
    @show configDict
    return configDict
end


"""
    key2symbol(d)
make the dict key to Symbol type
if the `Content-Type` of info file is not `application/json`,
the default parsing of JSON file will have a key type of `String`
"""
function key2symbol(d::Dict{Symbol, Any})
    return d
end

function key2symbol(d::Dict{String, Any})
    ret = Dict{Symbol, Any}()
    for (k,v) in d
        ret[Symbol(k)] = v
    end
    return ret
end

function key2symbol(d::String)
    JSON.parse(d; dicttype = Dict{Symbol,Any})
end
