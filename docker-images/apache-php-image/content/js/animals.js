$(function() {
        console.log("Loading animals");

        function loadAnimals() {
                $.getJSON( "/api/animals/", function( animals ) {
                        console.log(animals);
                        var message = "No animal is here";
                        if( animals.length > 0 ) {
                                message = "Race : " + animals[0].race + " / Nom : " + animals[0].name;
                        }
                        $(".masthead-subheading").text(message);
                });
        };

        loadAnimals();
        setInterval( loadAnimals, 2000);
});