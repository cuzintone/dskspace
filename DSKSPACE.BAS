DECLARE FUNCTION GetDiskFree& (Drive$)
DECLARE SUB MSDOS (inreg AS ANY, outreg AS ANY)
DECLARE FUNCTION GetDiskSize& (Drive$)
DECLARE FUNCTION MakeWord! (num AS INTEGER)

'*****************************************************************************
'*                                                                           *
'*                         DSKSPACE                                          *
'-----------------------------------------------------------------------------
'*                                                                           *
'*  Purpose:            Show available disk space and total disk space for   *
'*                      FAT12/16 file systems under DOS/FreeDOS              *
'*                      QuickBASIC/Microsoft Basic PDS and the QB.QLB must   *
'*                      be loaded using QB (or QBX) /L QB before loading and *
'*                      running this file                                    *
'-----------------------------------------------------------------------------
'*     Author:          Antony Gordon                                        *
'*     Developed on:   06/17/2022                                            *
'*****************************************************************************


'$INCLUDE: 'qb.bi'                          ' Include file for interrupt call

' These variables are for testing purposes
DIM c AS LONG
DIM d AS LONG
DIM Drive AS STRING
Drive = "C"
c = GetDiskFree(Drive)
d = GetDiskSize(Drive)
CLS
PRINT "Testing DiskSpace Routines (FAT12/FAT16)"

PRINT "Determining Free disk space on drive "; Drive
PRINT "Free disk space: "; c; "bytes"
PRINT "Free disk space: "; c \ 1024; " Kbytes"
PRINT "Free disk space: "; c \ (1024! * 1024!); " Mbytes"
PRINT "Free disk space: "; c \ (1024! * 1024! * 1024!); " GBytes"

PRINT : PRINT "Determining total disk space on drive "; Drive
PRINT "Total disk space: "; d; "bytes"
PRINT "Total disk space: "; d \ 1024; " Kbytes"
PRINT "Total disk space: "; d \ (1024! * 1024!); " Mbytes"
PRINT "Total disk space: "; CINT(d / (1024! * 1024! * 1024!) * 100) / 100; " GBytes"

'*****************************************************************************
'*                                                                           *
'*      GetDiskFree : Returns the free disk space available on the drive     *
'*      Input       : Drive letter                                           *
'*      Output      : Free space on the drive in bytes                       *
'*                                                                           *
'*****************************************************************************
FUNCTION GetDiskFree& (Drive$)
  DIM Regs AS RegType
  DIM Freespace AS LONG
  Regs.ax = &H36 * 256              ' Access the AH register and set to 0x36
  Regs.dx = (ASC(Drive$) - ASC("A") + 1)
  CALL MSDOS(Regs, Regs)
  IF Regs.ax <> &HFFFF THEN
    Freespace = Regs.cx
    GetDiskFree = Freespace * Regs.ax * Regs.bx
 ELSE
     GetDiskFree = 0
  END IF
END FUNCTION

'*****************************************************************************
'*                                                                           *
'*      GetDiskSize : Returns the disk size                                  *
'*      Input       : Drive letter                                           *
'*      Output      : Total disk size in bytes                               *
'*                                                                           *
'*****************************************************************************
FUNCTION GetDiskSize& (Drive$)
  DIM Regs AS RegType
  DIM c AS LONG

  Regs.ax = &H36 * 256
  Regs.dx = (ASC(Drive$) - ASC("A") + 1)
  CALL MSDOS(Regs, Regs)
  IF Regs.ax <> &HFFFF THEN
    c = MakeWord(Regs.dx)
    GetDiskSize = c * Regs.ax * Regs.cx
  ELSE
    GetDiskSize = 0
  END IF
END FUNCTION

'*****************************************************************************
'*                                                                           *
'*      MakeWord    : Overcomes BASICs limitation on integers by converting  *
'*                    them to a long number, which then allows bit shift     *
'*                    operations on a negative number using integer division.*
'*      Input       : The integer number                                     *
'*      Output      : The corresponding long number                          *
'*                                                                           *
'*****************************************************************************
FUNCTION MakeWord! (num AS INTEGER)
IF num < 0 THEN
  MakeWord = 65536! + num
ELSE
  MakeWord = num
END IF
END FUNCTION

'*****************************************************************************
'*                                                                           *
'*      MSDOS       : Calls the DOS API functions using INTERRUPT            *
'*      Input       : Registers                                              *
'*      Output      : Registers                                              *
'*****************************************************************************
SUB MSDOS (inreg AS RegType, outreg AS RegType)
     CALL INTERRUPT(&H21, inreg, outreg)
END SUB

