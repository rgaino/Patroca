Parse.Cloud.define("totalCommentsForItems", function(request, response) {

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
		  
			var returnData = {item_ids: [], item_comments: []};

			for (var i = 0; i < results.length; ++i) {
				var item_id = results[i].get("item_id").id;
				var exists = _.find(returnData.item_ids, function(id) { return id == item_id; });
				if(!exists) {
					returnData.item_ids.push(item_id);
					returnData.item_comments.push(0);
				}
				returnData.item_comments[returnData.item_ids.indexOf(item_id)] += 1;
			}

			response.success(returnData);
		},
		error: function() {
		  response.error("Lookup failed");
		}
	});

});