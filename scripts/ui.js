function Section(id, name) {
	this.id = ko.observable(id);
	this.name = ko.observable(name);
}

function NavModel() {
	const self = this;
	self.sections = ko.observableArray([
		new Section("spectrum", "Upload spectrum file"),
		new Section("survey", "Upload survey data"),
		new Section("programmatic", "Upload programmatic data"),
		new Section("review-input", "Review input data"),
		new Section("fit", "Fit model"),
		new Section("run", "Run model")
	]);
	self.currentSection = ko.observable(self.sections()[0]);
	self.onClick = function(section) {
		self.currentSection(section);
	};
}

ko.applyBindings(new NavModel());