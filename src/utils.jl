const DEFAULT_CONFIG_FILENAME = "info"

const DATATYPE_MAP = Dict(
    "uint8"     => "UInt8",
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
    for d in infoDict["scales"]
        if d["key"] == k
            if infoDict["num_channels"] == 1
                chunkSize   = d["chunk_sizes"][1]
            else
                chunkSize   = [d["chunk_sizes"][1]..., infoDict["num_channels"]]
            end
            encoding    = d["encoding"]
            totalSize   = d["size"]
            offset      = d["voxel_offset"]
        end
    end

    configDict = Dict(
        "chunkSize"     => chunkSize,
        "dataType"      => DATATYPE_MAP[ infoDict["data_type"] ]
    )
end
