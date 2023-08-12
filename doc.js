(function () {
	const docnav = document.querySelector('.doc-nav');
	const active = docnav.querySelector('li.active');
	active?.scrollIntoView({ block: 'center', inline: 'nearest' });
	setupMobileToggle();
	setupDarkMode();
	setupScrollSpy();
	setupSearch();
	setupCollapse();
})();

function setupScrollSpy() {
	const sections = document.querySelectorAll('section');
	const sectionPositions = Array.from(sections).map((section) => section.offsetTop);
	let scrollPos = 0;
	window.addEventListener('scroll', () => {
		const toc = document.querySelector('.doc-toc');
		// Reset classes
		toc.querySelectorAll('a[class="active"]').forEach((link) => link.classList.remove('active'));
		// Set current menu link as active
		let scrollPosition = document.documentElement.scrollTop || document.body.scrollTop;
		for (const [i, position] of sectionPositions.entries()) {
			if (position >= scrollPosition) {
				const section = sections[i];
				const link = toc.querySelector('a[href="#' + section.id + '"]');
				if (link) {
					link.classList.add('active');
					const tocHeight = toc.clientHeight;
					const scrollTop = toc.scrollTop;
					if (
						document.body.getBoundingClientRect().top < scrollPos &&
						scrollTop < link.offsetTop - 10
					) {
						toc.scrollTop = link.clientHeight + link.offsetTop - tocHeight + 10;
					} else if (scrollTop > link.offsetTop - 10) {
						toc.scrollTop = link.offsetTop - 10;
					}
				}
				break;
			}
		}
		scrollPos = document.body.getBoundingClientRect().top;
	});
}

function setupMobileToggle() {
	document.getElementById('toggle-menu').addEventListener('click', () => {
		const docNav = document.querySelector('.doc-nav');
		const isHidden = docNav.classList.contains('hidden');
		docNav.classList.toggle('hidden');
		const search = docNav.querySelector('.search');
		const searchHasResults = search.classList.contains('has-results');
		if (isHidden && searchHasResults) {
			search.classList.remove('mobile-hidden');
		} else {
			search.classList.add('mobile-hidden');
		}
		const content = docNav.querySelector('.content');
		content.classList.toggle('hidden');
		content.classList.toggle('show');
	});
}

function setupDarkMode() {
	const html = document.querySelector('html');
	const darkModeToggle = document.getElementById('dark-mode-toggle');
	darkModeToggle.addEventListener('click', () => {
		html.classList.toggle('dark');
		const isDarkModeEnabled = html.classList.contains('dark');
		localStorage.setItem('dark-mode', isDarkModeEnabled);
		darkModeToggle.setAttribute('aria-checked', isDarkModeEnabled);
	});
}

function setupSearch() {
	const searchInput = document.getElementById('search');
	const onInputChange = debounce((e) => {
		const searchValue = e.target.value.toLowerCase();
		const docNav = document.querySelector('.doc-nav');
		const menu = docNav.querySelector('.content');
		const search = docNav.querySelector('.search');
		if (searchValue === '') {
			// reset to default
			menu.style.display = '';
			if (!search.classList.contains('hidden')) {
				search.classList.add('hidden');
				search.classList.remove('has-results');
			}
		} else if (searchValue.length >= 2) {
			// search for less than 2 characters can display too much results
			search.innerHTML = '';
			menu.style.display = 'none';
			if (search.classList.contains('hidden')) {
				search.classList.remove('hidden');
				search.classList.remove('mobile-hidden');
				search.classList.add('has-results');
			}
			// cache length for performance
			let foundModule = false;
			const ul = document.createElement('ul');
			search.appendChild(ul);
			for (const [i, title] of searchModuleIndex.entries()) {
				// no toLowerCase needed because modules are always lowercase
				if (title.indexOf(searchValue) === -1) {
					continue;
				}
				foundModule = true;
				// [description, link]
				const data = searchModuleData[i];
				const el = createSearchResult({
					badge: 'module',
					description: data[0],
					link: data[1],
					title: title,
				});
				ul.appendChild(el);
			}
			if (foundModule) {
				const hr = document.createElement('hr');
				hr.classList.add('separator');
				search.appendChild(hr);
			}
			let results = [];
			for (const [i, title] of searchIndex.entries()) {
				if (title.toLowerCase().indexOf(searchValue) === -1) {
					continue;
				}
				// [badge, description, link]
				const data = searchData[i];
				results.push({
					badge: data[0],
					description: data[1],
					link: data[2],
					title: data[3] + ' ' + title,
				});
			}
			results.sort((a, b) => (a.title < b.title ? -1 : a.title > b.title ? 1 : 0));
			const ul_ = document.createElement('ul');
			search.appendChild(ul_);
			results.forEach((result) => {
				const el = createSearchResult(result);
				ul_.appendChild(el);
			});
		}
	});
	searchInput.addEventListener('input', onInputChange);
	setupSearchKeymaps();
}

function setupSearchKeymaps() {
	const searchInput = document.querySelector('#search input');
	// Keyboard shortcut indicator
	const searchKeys = document.createElement('div');
	const modifierKeyPrefix = navigator.platform.includes('Mac') ? '⌘' : 'Ctrl';
	searchKeys.setAttribute('id', 'search-keys');
	searchKeys.innerHTML = '<kbd>' + modifierKeyPrefix + '</kbd><kbd>k</kbd>';
	searchInput.parentElement?.appendChild(searchKeys);
	searchInput.addEventListener('focus', () => searchKeys.classList.add('hide'));
	searchInput.addEventListener('blur', () => searchKeys.classList.remove('hide'));
	// Global shortcuts to focus searchInput
	document.addEventListener('keydown', (ev) => {
		if (ev.key === '/' || ((ev.ctrlKey || ev.metaKey) && ev.key === 'k')) {
			ev.preventDefault();
			searchInput.focus();
		}
	});
	// Shortcuts while searchInput is focused
	let selectedIdx = -1;
	function selectResult(results, newIdx) {
		if (selectedIdx !== -1) {
			results[selectedIdx].classList.remove('selected');
		}
		results[newIdx].classList.add('selected');
		results[newIdx].scrollIntoView({ behavior: 'smooth', block: 'end', inline: 'nearest' });
		selectedIdx = newIdx;
	}
	searchInput.addEventListener('keydown', (ev) => {
		const searchResults = document.querySelectorAll('.search .result');
		switch (ev.key) {
			case 'Escape':
				searchInput.blur();
				break;
			case 'Enter':
				if (!searchResults.length || selectedIdx === -1) break;
				searchResults[selectedIdx].querySelector('a').click();
				break;
			case 'ArrowDown':
				ev.preventDefault();
				if (!searchResults.length) break;
				if (selectedIdx >= searchResults.length - 1) {
					// Cycle to first if last is selected
					selectResult(searchResults, 0);
				} else {
					// Select next
					selectResult(searchResults, selectedIdx + 1);
				}
				break;
			case 'ArrowUp':
				ev.preventDefault();
				if (!searchResults.length) break;
				if (selectedIdx <= 0) {
					// Cycle to last if first is selected (or select it if none is selcted yet)
					selectResult(searchResults, searchResults.length - 1);
				} else {
					// Select previous
					selectResult(searchResults, selectedIdx - 1);
				}
				break;
			default:
				selectedIdx = -1;
		}
	});
}

function createSearchResult(data) {
	const li = document.createElement('li');
	li.classList.add('result');
	const a = document.createElement('a');
	a.href = data.link;
	a.classList.add('link');
	li.appendChild(a);
	const defintion = document.createElement('div');
	defintion.classList.add('definition');
	a.appendChild(defintion);
	if (data.description) {
		const description = document.createElement('div');
		description.classList.add('description');
		description.textContent = data.description;
		a.appendChild(description);
	}
	const title = document.createElement('span');
	title.classList.add('title');
	title.textContent = data.title;
	defintion.appendChild(title);
	const badge = document.createElement('badge');
	badge.classList.add('badge');
	badge.textContent = data.badge;
	defintion.appendChild(badge);
	return li;
}

function setupCollapse() {
	const dropdownArrows = document.querySelectorAll('.dropdown-arrow');
	dropdownArrows.forEach((arrow) => {
		arrow.addEventListener('click', (e) => {
			const parent = e.target.parentElement.parentElement.parentElement;
			parent.classList.toggle('open');
		});
	});
}

function debounce(func, timeout) {
	let timer;
	return (...args) => {
		const next = () => func(...args);
		if (timer) {
			clearTimeout(timer);
		}
		timer = setTimeout(next, timeout > 0 ? timeout : 300);
	};
}
