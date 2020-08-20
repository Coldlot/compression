import Foundation
import Compression

let jsonString: String = """
{
    "glossary": {
        "title": "example glossary",
        "GlossDiv": {
            "title": "S",
            "GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
                    "SortAs": "SGML",
                    "GlossTerm": "Standard Generalized Markup Language",
                    "Acronym": "SGML",
                bbrev": "ISO 8879:1986",
                    "GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
                        "GlossSeeAlso": ["GML", "XML"]
                    },
                    "GlossSee": "markup"
                }
            }
        }
    }
}
"""

/// convert `String` to `Data`
guard let inputData = jsonString.data(using: .utf8) else {
    fatalError("Invalid json string!")
}
/// get the  amount of `bytes`
let inputDataSize = inputData.count

/// garanty that `UInt8` is a 1 byte
let byteSize = MemoryLayout<UInt8>.stride
let bufferSize = inputDataSize / byteSize

/// buffer for `copy to`
let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

/// beffer for `copy from`
var sourceBuffer = Array<UInt8>(repeating: 0, count: bufferSize)
inputData.copyBytes(to: &sourceBuffer, count: inputDataSize)

/// compessing and getting the compessing size
let compressedSize = compression_encode_buffer(destinationBuffer, inputDataSize, &sourceBuffer, inputDataSize, nil, COMPRESSION_ZLIB)

print("inputSize: \(inputDataSize), compressedSize: \(compressedSize)")

/// Decompessing

/// check out that size is not 0
guard compressedSize != 0 else {
    fatalError("Compression size == 0!")
}

/// getting date from buffer and cast to `Data` type
let encodedData: Data = NSData(bytesNoCopy: destinationBuffer, length: compressedSize) as Data

/// buffer for `copy to`
let destinationBuffer_second = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

/// buffer for `copy from`
var sourceBuffer_second = Array<UInt8>(repeating: 0, count: compressedSize)
encodedData.copyBytes(to: &sourceBuffer_second, count: compressedSize)

/// decoding the data
let decodedSize = compression_decode_buffer(destinationBuffer_second, bufferSize, &sourceBuffer_second, compressedSize, nil, COMPRESSION_ZLIB)

print("decodedSize: \(decodedSize)")
