# <p align="center">nimitai</p>

## Introduction & motivation
Nimitai is a parser generator implemented as a native Nim library.  
It accepts [ksy grammars](https://doc.kaitai.io/ksy_reference.html) which work best for describing binary data structures.

Essentially it's an alternative [Kaitai Struct](https://kaitai.io/) compiler implementation only for Nim. There are multiple justification for spending time on this:
- **Nim doesn't fit in:** Kaitai Struct's implementation assumes an object oriented language with class nesting. Nim doesn't fit this model, so using Kaitai Struct's code architecture is very tedious and the resulting code is not satisfactory.
- **AST codegen:** The code is generated on AST level instead of string level (source code), which is safer, easier to maintain, and of higher quality overall.
- **No compiler:** The whole implementation is one macro (instead of an external tool/compiler). This means you don't have to run any program or maintain generated modules. All you have to do is import nimitai and call a macro; then you have your parsing proc.

| Exported symbol | Production |
|-----------------|------------|
| `proc writeModule(ksj, module: string)` | nim module (source code) |
| `proc writeDll(ksj, dll: string)` | dynamic library |
| `macro injectParser(ksj: static[string])` | static library (compile time code embedding) |

## Example

hello_world.ksy
```yaml
meta:
  id: buffered_struct
  endian: le
seq:
  - id: len1
    type: u4
  - id: block1
    type: block
    size: len1
  - id: len2
    type: u4
  - id: block2
    type: block
    size: len2
  - id: finisher
    type: u4
types:
  block:
    seq:
      - id: number1
        type: u4
      - id: number2
        type: u4
```
buffered_struct.bin (hex view)
```bin
10 00 00 00 42 00 00 00 43 00 00 00 ff ff ff ff
ff ff ff ff 08 00 00 00 44 00 00 00 45 00 00 00
ee 00 00 00
```
test_nimitai.nim
```nim
import nimitai, kaitai_struct_nim_runtime
injectParser("buffered_struct.ksj")
let x = BufferedStruct.fromFile("buffered_struct.bin")

echo "Block1, number1: " & toHex(x.block1.number1.int64, 2)
echo "Block1, number2: " & toHex(x.block1.number2.int64, 2)
echo "Block2, number1: " & toHex(x.block2.number1.int64, 2)
echo "Block1, number2: " & toHex(x.block2.number2.int64, 2)
```
output:
```
Block1, number1: 42
Block1, number2: 43
Block2, number1: 44
Block1, number2: 45
```
## API
- One procedure -called `fromFile`- is generated.
- The procedure is namespaced under the file format type as written in the top-level meta section.
- The procedure accepts a file path and returns an object.
- The object has one field for each attribute described in the `.ksy` file.
- The object has the following additional fields:
  - `io`: holds the parsing stream
  - `root`: holds a reference to the root object
  - `parent`: holds a reference to the parent object

## Progress, missing components & plans
Nimitai is a work in progress. Even the most basic features are not implemented yet.

The following components are currently missing -I plan to implement these after nimitai is functional enough on a practical level-:
- **compile-time yaml parser:** Due to the lack of this Nim component, instead of the ksy file itself, nimitai uses the json equivalent of it as input for now (let's call this **ksj**). Any yaml -> json converter should do.
- **json schema validator:** Ideally, the syntax error reporting should be handled by this component, but a Nim implementation of it is currently missing.

## Will a `.ksy` file found in the [official KS gallery](https://formats.kaitai.io/) work as is?
**YES**. The official KSY grammar will be supported 100%.  
Alternatively, you will be able to configure nimitai so that it accepts Nim expressions and types instead of Kaitai Struct ones.
