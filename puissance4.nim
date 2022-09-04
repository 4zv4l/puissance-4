import os  ## shellcmd
import nre  ## reg.contains
import strutils  ## str.contains

const length = 7 ## column length

type
  Column = object
    free: uint
    content: array[length, string]
  Board = array[length, Column]

let p1 = "\e[31mO\e[0m" ## Player 1's icon (red)
let p2 = "\e[36mO\e[0m" ## Player 2's icon (blue)

template clear() =
  ## clear the screen using
  ## a shell command
  if defined(windows): discard execShellCmd("cls")
  discard execShellCmd("clear")

proc initBoard(): Board = 
  ## set all the case of the board to a '.'
  for column in result.mitems:
    column.free = length
    for c in column.content.mitems:
      c = "."

proc show(b: Board) =
  ## show the formatted board
  ## to the screen
  clear()
  for i in countup(0, length-1):
    stdout.write "|"
    for j in countup(0, length-1):
      stdout.write b[j].content[i] & "|"
    echo ""
  echo "-1-2-3-4-5-6-7-"

proc add(column: uint, player: string, board: var Board): bool =
  ## add player to the column if possible
  var 
    col = addr board[column-1]
    busy = length-col.free
  if col.free == 0: return false
  col.content[length-busy-1] = player
  col.free -= 1
  return true

proc to_string(b: Board): string =
  ## convert the board to a one line string
  var rep: string
  for i in countup(0, length-1):
    for j in countup(0, length-1):
      let c = b[j].content[i]
      if c == ".": rep = rep & "0"
      if c == p1: rep = rep & "1"
      if c == p2: rep = rep & "2"
  return rep

proc checkWinner(board: Board, round: uint): bool =
  ## check for winner (horizontal, vertical, diagonal)
  if round == 7*7:
    defer: 
      board.show()
      echo "no winner..."
    return true
  defer: board.show()
  # put the whole array on a one dimension array (string here)
  var rep: string = board.to_string()
  # check for horizontal winner
  if rep.contains("1111"): return true
  if rep.contains("2222"): return true
  # check for vertical winner
  if rep.contains(re"(1.{6}){4}"): return true
  if rep.contains(re"(.{6}1){4}"): return true
  if rep.contains(re"(2.{6}){4}"): return true
  if rep.contains(re"(.{6}2){4}"): return true
  # check for diagonal \ winner
  if rep.contains(re"(1.{7}){4}"): return true
  if rep.contains(re"(.{7}1){4}"): return true
  if rep.contains(re"(2.{7}){4}"): return true
  if rep.contains(re"(.{7}2){4}"): return true
  # check for diagonal / winner
  if rep.contains(re"(1.{5}){4}"): return true
  if rep.contains(re"(.{5}1){4}"): return true
  if rep.contains(re"(2.{5}){4}"): return true
  if rep.contains(re"(.{5}2){4}"): return true
  return false

proc getCol(p: string): uint =
  ## ask user for a column
  ## between 1 and 7
  var column: uint = 0
  while column == 0:
    stdout.write p & " which column(1-7): "
    let input = readline(stdin)
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

proc pause() = echo "Press Enter to continue"; discard readline(stdin)
## pause the program preventing the cmd 
## to quit without showing the winner

try:
  main()
  when defined(windows): pause()
except CatchableError as e:
  # doesn't show error message xD
  discard
