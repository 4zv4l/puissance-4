import os
import nre
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

# set all the case of the board to a '.'
proc initBoard(): Board = 
  for column in result.mitems:
    column.free = length
    for c in column.content.mitems:
      c = "."

proc to_string(b: Board): string =
  var rep: string
  for i in countup(0, length-1):
    for j in countup(0, length-1):
      let c = b[j].content[i]
      if c == ".": rep = rep & "0"
      if c == p1: rep = rep & "1"
      if c == p2: rep = rep & "2"
  return rep

# add player to the column if possible
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
  defer: board.show()
  if round == 7*7:
    defer: echo "no winner..."
    return true
  # put the whole array on a one dimension array (string here)
  var rep: string = board.to_string()
  # check for vertical winner
  if rep.contains("1111"): return true
  if rep.contains("2222"): return true
  # check for horizontal winner
  if rep.contains(re"(1.{6}){4}"): return true
  if rep.contains(re"(2.{6}){4}"): return true
  # check for diagonal winner
  if rep.contains(re"(1.{5}){4}"): return true
  if rep.contains(re"(1.{5}){4}"): return true
  return false

# ask user for a column
# between 1 and 7
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
