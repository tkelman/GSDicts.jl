#__precompile__(true)

module GSDicts

using GoogleCloud
using GoogleCloud.Utils.Storage
using JSON
import BigArrays: NoSuchKeyException

include("types.jl")
include("base.jl")
include("utils.jl")

end # end of module
