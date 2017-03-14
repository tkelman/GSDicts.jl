
const DEFAULT_CONFIG_FILENAME = "info"

# map datatype of python to Julia
const DATATYPE_MAP = Dict{String, String}(
    "uint8"     => "UInt8",
    "uint16"    => "UInt16",
    "uint32"    => "UInt32",
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
    # str = gsread( "gs://$(d.bucketName)/$(d.keyPrefix)/$(DEFAULT_CONFIG_FILENAME)" )
	authorize(d.googleSession; cache=true)
    # configDict = storage(:Object, :get, d.bucketName,
    #                     joinpath(d.keyPrefix, configFileName));
    keyPrefix = rstrip(d.keyPrefix,'/')
    k = basename( keyPrefix )
    dir = dirname( keyPrefix )
    infoDict = storage(:Object, :get, d.bucketName,
                        joinpath(dir, DEFAULT_CONFIG_FILENAME))
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