using GSDicts
using Base.Test

# test storage utility first
include(joinpath(dirname(@__FILE__), "google_cloud/storage_util.jl"))

credentialFileName = GSDicts.DEFAULT_CREDENTIAL_FILENAME

kv  = GSDict("gs://jpwu/test.bigarray.img"; credentialFileName = credentialFileName)

a = rand(UInt8, 50)

kv["test"] = a
b = kv["test"]

b = reinterpret(UInt8, b)

println("make sure that the value saved in the cloud is the same with local")
@test all(a .== b)

@test haskey(kv, "test")


info("delete the file in google cloud storage")
delete!(kv, "test")
