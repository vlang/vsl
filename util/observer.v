
module util

// Observer is an interface to objects that need to observe something
// the data observed by this observer is being update
pub interface Observer {
	update()
}

// Observable indicates that an object is observable; i.e. it has a list of interested observers
pub struct Observable {
pub mut:
	observers []Observer // list of interested parties
}

// add_observer adds an object to the list of interested observers
pub fn (mut o Observable) add_observer(obs Observer) {
	o.observers << obs
}

// notify_update notifies observers of updates
pub fn (o Observable) notify_update() {
	for obs in o.observers {
		obs.update()
	}
}
