var chance = require('chance');
var chance = new chance();

var express = require('express');
var app = express();

app.get('/', function(req, res){
    res.send(generateAnimals());
});

app.listen(3000, function(){
    console.log('Accepting HTTP requests on port 3000!');
});


function generateAnimals(){
	var numberOfAnimals = chance.integer({
		min : 1,
		max : 10
	});
	
	console.log(numberOfAnimals);
	
	var animals = [];
	
	for(var i = 0; i < numberOfAnimals; ++i){
        var gender = chance.gender();
		animals.push({
            'race'      : chance.animal(),
            'name'      : chance.first({ gender: gender }),
            'gender'    : gender,
            'age'       : chance.age({type: 'child'}),
            'country'   : chance.country({ full: true })
		});
	}
	console.log(animals);
	return animals;
}