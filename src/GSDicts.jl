__precompile__(true)

module GSDicts

using GoogleCloud
using GoogleCloud.Utils.Storage
using JSON
# support some internal compression
using ImageMagick
#import BigArrays: get_config_dict, NoSuchKeyException

include("types.jl")
include("base.jl")
include("utils.jl")

end # end of module
