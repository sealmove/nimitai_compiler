import macros, strutils
import ../../nimitai/exprlang, ../../nimitai, parser

proc test*(kst: Kst): NimNode =
  var asserts = newStmtList()

  for a in kst.asserts:
    asserts.add(
      nnkCommand.newTree(
        ident"check",
        infix(
          newDotExpr(
            ident"r",
            ident(a.actual)),
          "==",
          expr(a.expected).nim)))

  nnkCommand.newTree(
    ident"test",
    newLit(kst.id),
    newStmtList(
      newCall(
        ident"injectParser",
        newLit("../material/ksy/" & kst.id & ".ksy")),
      newLetStmt(
        ident"r",
        newCall(
          ident"fromFile",
          ident(kst.id.capitalizeAscii),
          newLit("../material/bin/" & kst.data))),
      asserts))

proc suite*(tests: varargs[NimNode], errorCode = -1): string =
  var res = newStmtList(
    nnkImportStmt.newTree(
      ident"../../nimitai",
      ident"../../../kaitai_struct_nim_runtime/kaitai_struct_nim_runtime",
      ident"matcher",
      ident"unittest",
      ident"options"),
    nnkPragma.newTree(
      newColonExpr(
        ident"experimental",
        newLit("dotOperators"))),
    nnkCommand.newTree(
        ident"suite",
        newLit("Nimitai Test Suite"),
        newStmtList().add(tests)))
  if errorCode != -1:
    res.add(
      newCall(
        ident"quit",
        newLit(errorCode)))

  res.toStrLit.strVal
