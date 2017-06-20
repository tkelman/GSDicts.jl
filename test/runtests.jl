using GSDicts

if isfile(joinpath(@__FILE__,"../.google_credentials.json"))
    credentialFileName = joinpath(@__FILE__,"../.google_credentials.json")
else 
    credentialFileName = GSDicts.DEFAULT_CREDENTIAL_FILENAME
end

kv  = GSDict("gs://jpwu/test.bigarray.img"; credentialFileName = credentialFileName)

a = rand(UInt8, 50)

kv["test"] = a

b = kv["test"]

b = reinterpret(UInt8, b)

println("make sure that the value saved in the cloud is the same with local")
Test.@test all(a .== b)

info("delete the file in google cloud storage")
delete!(kv, "test")
