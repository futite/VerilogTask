`timescale 1ns/1ps
`define DATA_WIDTH  32
`define DATA_DEPTH  4096
//`define ADDR_WIDTH 10
//`define FIGHT_MODE  "read_first" //可配置为“读优先，写优先，保持
`define RAM_STYLE_VAL  "block" //"distributed"  //配置为distribute或者block
`define FIGHT_MODE  3    //"read_first" 可配置为“读优先，写优先，保持 为1、2、3
`define ADDR_WIDTH 12
`define WAVE_TYPE  "tri"   //设置波形，可为sin、squ、tri分别为正弦、方波、三角波
