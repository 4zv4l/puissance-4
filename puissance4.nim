import os
import strutils
import rdstdin

# column length
const length = 7

type
  Column = object
    free: uint
    content: array[length, string]
  Board = array[length, Column] 

# player colored icons
let p1 = "\e[31mO\e[0m"
let p2 = "\e[36mO\e[0m"

template clear() =
  if defined(windows): discard execShellCmd("cls")
  discard execShellCmd("clear")

proc initBoard(): Board = 
  for column in result.mitems:
    column.free = length
    for c in column.content.mitems:
      c = "."

proc add(column: uint, player: string, board: var Board): bool =
  var 
    col = addr board[column-1]
    busy = length-col.free
  if col.free == 0: return false
  col.content[length-busy-1] = player
  col.free -= 1
  return true

proc show(b: Board) =
  clear()
  for i in countup(0, length-1):
    stdout.write "|"
    for j in countup(0, length-1):
      stdout.write b[j].content[i] & "|"
    echo ""
  echo "-1-2-3-4-5-6-7-"

# TODO: check for winner
proc checkWinner(board: Board, round: uint): bool =
  if round == 7*7:
    board.show()
    echo "no winner..."
    return true
  # check for vertical winner
  # check for horizontal winner
  # check for diagonal winner
  return false

proc getCol(p: string): uint =
  var column: uint = 0
  while column == 0:
    let input = readLineFromStdin(p & " which column(1-7): ")
    try:
      column = parseUInt(input)
      if column < 1 or column > 7:
        column = 0
        continue
    except: column = 0
  return column

proc main() =
  var board = initBoard()
  let ps = [p1, p2]
  var round: uint = 0
  while checkWinner(board, round) != true:
    board.show()
    let
      p = ps[round.int mod ps.len]
      column = getCol(p)
    if add(column, p, board) == false: continue
    round += 1

try:
  main()
except CatchableError as e:
  # doesn't show error message xD
  discard
