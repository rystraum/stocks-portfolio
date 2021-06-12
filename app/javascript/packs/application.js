import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';
import * as ActiveStorage from '@rails/activestorage';
import Alpine from 'alpinejs';

window.Alpine = Alpine;

Rails.start();
Turbolinks.start();
ActiveStorage.start();
Alpine.start();

document.addEventListener('turbolinks:load', function () {
});
