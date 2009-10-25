$(document).ready(function(){		
	
	// Set up the Slider
	var slideID = 1; // The initial slide (First one)
	var animation_active = false;
	
	// This initially hides all of the slides except the first one
	for (tempSlideNum=2;tempSlideNum<=total_images;tempSlideNum=tempSlideNum+1) 
	{
		$("#image-"+tempSlideNum).hide();
		$("#image-"+tempSlideNum).find("img").hide();
	}
	
	// NEXT SLIDE
	$("div.pagination").click(function(event){
														  
		if (this.id != slideID && animation_active == false) {
			
			animation_active = true;
			
			if (this.id == "next") {
				if (slideID != total_images) {
					whatClicked = "next";
					newslideID = slideID + 1;
					abort = false;
					if (newslideID != total_images) {
						$(".photoFrame").find('#next').fadeIn("normal");
						$(".photoFrame").find('#previous').fadeIn("normal");
					} else {
						$(".photoFrame").find('#next').fadeOut("normal");
						$(".photoFrame").find('#previous').fadeIn("normal");
					}
				} else {
					abort = true;
				}
			} else {
				if (slideID != 1) {
					whatClicked = "previous";
					newslideID = slideID - 1;
					abort = false;
					if (newslideID != 1) {
						$(".photoFrame").find('#previous').fadeIn("normal");
						$(".photoFrame").find('#next').fadeIn("normal");
					} else { 
						$(".photoFrame").find('#previous').fadeOut("normal");
						$(".photoFrame").find('#next').fadeIn("normal");
					}
				} else {
					abort = true;
				}
			}
			
			if (abort == true) {
				animation_active = false;
			} else {
				
				if (whatClicked == "next") {
					positionOne = "-287px";
					positionTwo = "287px";
					positionThree = "0";
					speedOne = 300;
				}
				
				if (whatClicked == "previous") {
					positionOne = "287px";
					positionTwo = "-287px";
					positionThree = "0";
					speedOne = 300;
				}
		
				$("#image-"+slideID).animate({left:positionOne},300, "easeInQuint", function(){
																
					$("#image-"+slideID).hide();
					$("#image-"+slideID).hide();
					
					// Wait until the above has finished, then do the rest
					slideID = newslideID;
					
					$("#image-"+slideID).css("left",positionTwo);
					$("#image-"+slideID).show();
					$("#image-"+slideID).show();	
					$("#image-"+slideID).animate({left:positionThree},300, "easeOutExpo", function(){
					
						animation_active = false;

					});
					
				});
			
			}
		
		}
		
	});

});