package main

import (
	"fmt"
	"image/color"
	"image/png"
	"os"
	"strings"
)
const visible_alpha=65535
func adjustColor(c color.Color) (uint8,uint8,uint8){
	r,g,b,a:=c.RGBA()
	if a!=visible_alpha{
		return 0,0,0
	}
	return (uint8)(r),(uint8)(g),(uint8)(b)
}
func main(){
	pathFileFrom:=os.Args[1]
	pathTo:=os.Args[2]
	file,err:=os.Open(pathFileFrom)
	if err!=nil{
		panic(err)
	} 
	defer file.Close()
	im,err:=png.Decode(file)
	if err!=nil{
		panic(err)
	}
	rec:=im.Bounds()
	dx:=rec.Dx()
	dy:=rec.Dy()
	fileTo,err:=os.Create(pathTo)
	if err!=nil{
		panic(err)
	}
	defer fileTo.Close()
	fileTo.WriteString("\033[0J")
	fileTo.WriteString("\033[1J")
	fileTo.WriteString("\x1b[0;0H")
	isBuffered:=false
	for y := range(dy){
		line:=strings.Builder{}
		line.WriteString("\x1b[E")
		if isBuffered{
			isBuffered=false
			continue
		}
		isBuffered=true
		for x := range(dx){
			r,g,b:=adjustColor(im.At(x,y))
			if (r==255 && g==255 && b==255){
				line.WriteString("\033[;0;0m ")
				continue
			}
			fmt.Fprintf(&line,"\x1b[38;2;%d;%d;%dm\x1b[48;2;%d;%d;%dm\u25a0", r,g,b,r,g,b)
		}
		fileTo.WriteString(line.String())
	}
		fileTo.WriteString(("\033[;0;0m"))
}
