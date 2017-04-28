const DEFAULT_CREDENTIAL_FILENAME = expanduser("~/.google_credentials.json")
# const DEFAULT_CREDENTIAL = GoogleCredentials(expanduser("~/credentials.json"))
const DEFAULT_VALUE_FORMAT = :identity

function Base.delete!( d::GSDict, key::String )
	authorize( d.googleSession )
    # authorize( d.kvStore.session )
    delete!( d.kvStore, joinpath(d.keyPrefix, key) )
end

function Base.setindex!( d::GSDict, value::Any, key::String )
	authorize( d.googleSession )
    # authorize( d.kvStore.session )
    d.kvStore[joinpath(d.keyPrefix, key)] = value
end

function Base.getindex( d::GSDict, key::String)
	authorize( d.googleSession )
    try 
        return d.kvStore[joinpath(d.keyPrefix, key)]
    catch e 
        println("no such key in Google Cloud Storage: $(e), will fill with zeros")
        throw(ZeroChunkException)
    end
end

function Base.keys( d::GSDict )
    # keyList = keys( d.kvStore )
    # for i in eachindex(keyList)
    #     keyList[i] = joinpath(d.keyPrefix, keyList[i])
    # end
    # @show keyList
	authorize(d.googleSession)
    ds = storage(:Object, :list, d.bucketName; prefix=d.keyPrefix, fields="items(name)")
    ret = Vector{String}()
    for i in eachindex(ds)
        chunkFileName = replace(ds[i][:name], "$(rstrip(d.keyPrefix, '/'))/", "" )
        push!(ret, chunkFileName)
    end
    return ret
end
