# nimitai
## `.ksy` metaparser ([Kaitai Struct](https://kaitai.io/) as a macro)

### How will it look like?
A vague usage demo:
```nim
import nimitai

generateParser("/path/to/my/ksy/file")

let x = myFileFormat.fromFile("/path/to/my/bin/file")

# Access x's structured data (fields) here.
```
### How does it work?
- [npeg](https://github.com/zevv/npeg) is used to parse a `.ksy` file (special thanks to [zevv](https://github.com/zevv) for this awesome library <3).
- The ksy AST is used to generate procedures for parsing a file into a structured Nim object.

*everything is done at compile-time*

### What does it bring to the table?
Up until now there is no library in any programming language for parsing an arbitary file. If a library for your specific format does not exist in your language, you have to create it. This can either be done **by hand** or by using a **file parser generator** like [Kaitai Struct](https://kaitai.io/) or if your format is relatively simple, serialization programs like [Protocol Buffers](https://developers.google.com/protocol-buffers) can work too.

Nimitai does away with all this machinary! The advantages are several:
- Zero dependence on external compiler tools
- Each time you change the `.ksy` file, the parser is automatically recompiled along with your project
- Better quality of generated code since it's done on AST level

*this allows for better and easier integration of parsers into your project*

### Will a `.ksy` file found in [Kaitai Struct Collection Gallery](https://formats.kaitai.io/) work as is?
Mostly yes. The original `.ksy` syntax will be supported 100%. However, nimitai might have different defaults; for example:
- Nim expressions instead of Kaitai Struct expressions (you will be able to toggle this)

### Progress
The project has hit the limitations of what is possible in metaparsing today.  
Specifically it stretches Nim VM too much leading to a crash.

Nim VM uses 16bit adressing which is not enough for a relatively hefty parser.  
For this project to progress any further, the VM's addressing mode has be extended to 32bit.

This is demonstrated as follows (credits to zevv):
```nim
import macros

macro foo(): untyped =
  let s = newStmtList()
  for i in 1..16384:
    s.add nnkCommand.newTree(newIdentNode("echo"), newLit(i))
  newTree(nnkWhileStmt, ident "true", s)

static:
  foo()
```
