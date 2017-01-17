module GSDicts

using GoogleCloud

export GSDict

GSDict = KeyStore

function GSDict(  )


function serialize_to_uint8_vector(x)
    io = IOBuffer()
    serialize(io, x)
    takebuf_array(io)
end

deserialize_from_vector(x) = deserialize(IOBuffer(x))


end # end of module
