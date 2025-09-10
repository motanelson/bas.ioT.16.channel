
' grid.bas - compilar: fbc grid.bas
' funciona em Windows, DOS (extender) e Linux, sem windows.bi

Const WIN_W = 800
Const WIN_H = 600
Const CELLS_PER_ROW = 4
Const CELLS_PER_COL = 4
Const CELL_SIZE = 50
Const GAP = 10

Dim Shared states(0 To CELLS_PER_ROW * CELLS_PER_COL - 1) As Integer

Const YELLOW = RGB(255,255,0)
Const WHITE  = RGB(255,255,255)
Const BLACK  = RGB(0,0,0)

Sub drawGrid()
    ScreenLock
    Cls
    Line (0,0)-(WIN_W,WIN_H), YELLOW, BF

    Dim grid_w As Integer = CELLS_PER_ROW * CELL_SIZE + (CELLS_PER_ROW - 1) * GAP
    Dim grid_h As Integer = CELLS_PER_COL * CELL_SIZE + (CELLS_PER_COL - 1) * GAP
    Dim start_x As Integer = (WIN_W - grid_w) \ 2
    Dim start_y As Integer = (WIN_H - grid_h) \ 2

    For r As Integer = 0 To CELLS_PER_COL-1
        For c As Integer = 0 To CELLS_PER_ROW-1
            Dim idx As Integer = r * CELLS_PER_ROW + c
            Dim x1 As Integer = start_x + c * (CELL_SIZE + GAP)
            Dim y1 As Integer = start_y + r * (CELL_SIZE + GAP)
            Dim x2 As Integer = x1 + CELL_SIZE - 1
            Dim y2 As Integer = y1 + CELL_SIZE - 1

            Dim col As UInteger = IIf(states(idx) = 1, BLACK, WHITE)

            Line (x1, y1) - (x2, y2), col, BF
            Line (x1, y1) - (x2, y2), BLACK, B
        Next
    Next
    ScreenUnlock
End Sub

Function hitCell(mx As Integer, my As Integer) As Integer
    Dim grid_w As Integer = CELLS_PER_ROW * CELL_SIZE + (CELLS_PER_ROW - 1) * GAP
    Dim grid_h As Integer = CELLS_PER_COL * CELL_SIZE + (CELLS_PER_COL - 1) * GAP
    Dim start_x As Integer = (WIN_W - grid_w) \ 2
    Dim start_y As Integer = (WIN_H - grid_h) \ 2

    If mx < start_x Or mx >= start_x + grid_w Then Return -1
    If my < start_y Or my >= start_y + grid_h Then Return -1

    Dim col As Integer = (mx - start_x) \ (CELL_SIZE + GAP)
    Dim row As Integer = (my - start_y) \ (CELL_SIZE + GAP)

    Dim cell_x As Integer = start_x + col * (CELL_SIZE + GAP)
    Dim cell_y As Integer = start_y + row * (CELL_SIZE + GAP)

    If mx >= cell_x And mx < cell_x + CELL_SIZE And my >= cell_y And my < cell_y + CELL_SIZE Then
        Return row * CELLS_PER_ROW + col
    End If

    Return -1
End Function

' ===================== MAIN =====================
ScreenRes WIN_W, WIN_H, 32
WindowTitle "Janela Amarela - FreeBASIC Grid"

SetMouse 1

drawGrid()

Dim mx As Integer, my As Integer, wheel As Integer, buttons As Integer
Dim lastBtn As Integer

Do
    GetMouse(mx, my, wheel, buttons)

    If (buttons And 1) AndAlso (lastBtn And 1) = 0 Then
        ' Clique do botão esquerdo
        Dim idx As Integer = hitCell(mx, my)
        If idx >= 0 Then
            states(idx) = 1 - states(idx)
            drawGrid()
            Dim cmd As String
            cmd = "command " & (idx+1) & " " & states(idx)
            Print "Executar: "; cmd
            Shell cmd
        End If
    End If

    lastBtn = buttons
    Sleep 10
Loop Until InKey = Chr(27)  ' sai com ESC
