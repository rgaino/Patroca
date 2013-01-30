
/*
Returns a list of item_ids and how many comments each one has
*/
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


/*
Sends a notification to users subscribed to this item's comments
*/
Parse.Cloud.afterSave("Item_Comments", function(request) {

	var commenterId = request.object.get("user_id").id;
	var subscribeChannel = "comments_on_item_" + request.object.get("item_id").id;
	console.log("Sending push notification for users subscribed to this item's comments (" + subscribeChannel + "), except the comment's author (" + commenterId + ")");

	var User = Parse.Object.extend("User");
	var queryUser = new Parse.Query(User);

	queryUser.get(commenterId, {
		success: function(user) {
			var commenterName = user.get("name");
			var message = "Novo comentário de " + commenterName;
			//send Push notification
			Parse.Push.send({
			  channels: [ subscribeChannel ],
			  data: {
			    alert: message
			  }
			}, {
			  success: function() {
			    console.log("Push successful for " + subscribeChannel + "with message + '" + message + "'");
			  },
			  error: function(error) {
			    console.log("Push failed for " + subscribeChannel);
			  }
			});

		},
		error: function(object, error) {
			console.log("Lookup failed for user " + commenterId);
		}
	});





});
