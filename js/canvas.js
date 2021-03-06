
const urlParams = new URLSearchParams(window.location.search);
var focus = urlParams.get('focus');


var c = document.getElementById("myCanvas");
var ctx = c.getContext("2d");

c.style.width = window.innerWidth - 10;
c.style.height = window.innerHeight - 40;
var square_length = 100;

var tile_width = Math.round(c.width / square_length);
var tile_height = Math.round(c.height / square_length);


function blank(ctx){
    ctx.beginPath();
    ctx.rect(0, 0, c.width, c.height);
    ctx.fillStyle = "white";
    ctx.fill();
};
function tick_frequency(){
    return(60);
};
function day_period() {
    return(60 * tick_frequency());
};
function year_period(){
    return(20 * day_period());
};
function hour(time){
    var dp = day_period();
    return(Math.round((time + (dp / 2)) % dp));
};
function season(time) {
    var yp = year_period();
    return(Math.round((time + (yp / 2)) % yp));
};
function planet_pronation(){
    return(0.2);
};
function day(time, x, y) {
    var dp = day_period();
    var yp = year_period();
    var width = 100;
    var height = 100;
    var pi = Math.PI;
    var day_wave = Math.cos(2*pi*((hour(time)/dp) - (x/width)));
    var latitude_effect = ((Math.cos(2*pi*y/height)+1)/2);
    var season_wave = (Math.cos(2*pi*season(time)/yp));
    var s = (latitude_effect * season_wave);
    var pronation = 1 + planet_pronation();
    return((day_wave + (pronation * s)) > 0);
};

async function test(){
    var board0 = await rpc.apost(["read"]);
    var time = board0[1];
    var board = board0[2];

    //console.log(time);
    
    //console.log(JSON.stringify(board));
    blank(ctx);
    for(var i = 1; i<board.length; i++){
        for(var j = 1; j<board[1].length; j++){
            //console.log(day(time, j, i));
            if(!(day(time, j, i))){
                draw(i, j, "grey");
            };
            var location = board[i][j];
            //console.log(location);
            var food = location[1];
            var species = location[4];
            var direction = location[3];
            if(food === 1){
                draw(i, j, "food");
            };
            if((species).toString() === focus){
                draw(i, j, "animal", 62); 
            } else if(!(species === 0)){
                draw(i, j, "animal", species);
            };
            if(!(direction === 0)){
                draw_direction(i, j, direction);
            };
        };
    };
    setTimeout(test, 500);
};

setTimeout(test, 100);

/*
setTimeout(function(){
    draw(0, 0, "food");
    draw(50, 50, "food");
    draw(99, 99, "food");
}, 100);
*/
var blue_left_pic = document.getElementById('blue_left');
var blue_right_pic = document.getElementById('blue_right');
var cyan_left_pic = document.getElementById('cyan_left');
var cyan_right_pic = document.getElementById('cyan_right');
var green_left_pic = document.getElementById('green_left');
var green_right_pic = document.getElementById('green_right');
var light_blue_left_pic = document.getElementById('light_blue_left');
var light_blue_right_pic = document.getElementById('light_blue_right');
var orange_left_pic = document.getElementById('orange_left');
var orange_right_pic = document.getElementById('orange_right');
var pink2_left_pic = document.getElementById('pink2_left');
var pink2_right_pic = document.getElementById('pink2_right');
var pink_left_pic = document.getElementById('pink_left');
var pink_right_pic = document.getElementById('pink_right');
var red_left_pic = document.getElementById('red_left');
var red_right_pic = document.getElementById('red_right');
var white_left_pic = document.getElementById('white_left');
var white_right_pic = document.getElementById('white_right');
var yellow_left_pic = document.getElementById('yellow_left');
var yellow_right_pic = document.getElementById('yellow_right');
var up_pic = document.getElementById('up');
var down_pic = document.getElementById('down');
var right_pic = document.getElementById('right');
var left_pic = document.getElementById('left');
var right_pics = [
    //blue_right_pic,
    cyan_right_pic,
    green_right_pic,
    light_blue_right_pic,
    orange_right_pic,
    pink2_right_pic,
    pink_right_pic,
    red_right_pic,
    //white_right_pic,
    yellow_right_pic
];
var left_pics = [
    //blue_left_pic,
    cyan_left_pic,
    green_left_pic,
    light_blue_left_pic,
    orange_left_pic,
    pink2_left_pic,
    pink_left_pic,
    red_left_pic,
    //white_left_pic,
    yellow_left_pic
];

function draw_direction(y, x, d){
    x = Math.round(x * c.width / square_length);
    y = Math.round(y * c.height / square_length);
    if(d === 4){
        ctx.drawImage(up_pic, x, y, tile_width, tile_height);
    } else if(d === 1){
        ctx.drawImage(down_pic, x, y, tile_width, tile_height);
    } else if(d === 3){
        ctx.drawImage(right_pic, x, y, tile_width, tile_height);
    } else if(d === 2){
        ctx.drawImage(left_pic, x, y, tile_width, tile_height);
    };
};

function draw(y, x, thing, species) {
    x = Math.round(x * c.width / square_length);
    y = Math.round(y * c.height / square_length);
    //console.log([x,y]);
    var pic;
    var food_pic = document.getElementById('food');
    var grey_pic = document.getElementById('grey');
    if(thing === "food") {
        ctx.drawImage(
            food_pic, x, y,
            tile_width, tile_height);
    } else if(thing === "grey") {
        ctx.drawImage(
            grey_pic, x, y,
            tile_width, tile_height);
    } else if(thing === "animal"){
        //console.log(species);
        var pic1 = species_to_pic1(species);
        var pic2 = species_to_pic2(species);
        ctx.drawImage(
            pic1, x, y,
            tile_width, tile_height);
        ctx.drawImage(
            pic2, x, y,
            tile_width, tile_height);
    }
};

function species_to_pic1(species) {
    return(left_pics[(species % (left_pics.length))]);
};
function species_to_pic2(species) {
    var s2 = Math.floor(species / 10);
    return(right_pics[(s2 % (right_pics.length))]);

};

/*
ctx.moveTo(-40,0);
ctx.lineTo(0, c.height);
ctx.lineTo(50, c.height);
ctx.fillStyle = "blue";
ctx.fill();
*/
