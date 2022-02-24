({
	handleClick : function(component) {
		console.log('datecell clicked');
		var click = component.getEvent("BrDateCellClick");
		click.setParams({"class": component.get("v.tdClass")});
		click.fire();
	}
})