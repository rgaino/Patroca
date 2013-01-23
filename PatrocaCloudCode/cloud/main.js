Parse.Cloud.define("totalCommentsForItems", function(request, response) {

	console.log("BEGIN ---------");

	var _ = require("underscore");

	var query = new Parse.Query("Item_Comments");

	var pointers = _.map(request.params.item_ids_array, function(item_id) {
	var pointer = new Parse.Object("Item");
	pointer.id = item_id;
	return pointer;
	});

	query.containedIn("item_id", pointers);

	query.find({
	success: function(results) {
	  
		var returnArray = new Parse.Object;


		for (var i = 0; i < results.length; ++i) {
			item_id = results[i].get("item_id");
			// console.log(item_id);
			returnArray.set(item_id, i);
		}
		
		console.log("---------");
		console.log(returnArray);

		// var sum = 0;
		// for (var i = 0; i < results.length; ++i) {
		// 	sum += 1; //results[i].get("stars");
		// }

		response.success(results.length);
		},
	error: function() {
	  response.error("Lookup failed");
	}
});

});