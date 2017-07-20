#__precompile__(true)

module GSDicts

using GoogleCloud
# add new value format option (a dirty fix)
GoogleCloud.collection.val_format_map[:identity] = (identity, identity)

using JSON
#import BigArrays: NoSuchKeyException
include("google_cloud/storage_util.jl")
using .StorageUtil

include("types.jl")
include("base.jl")
include("utils.jl")

end # end of module
