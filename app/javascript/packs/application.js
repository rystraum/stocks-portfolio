import Rails from '@rails/ujs';
import * as ActiveStorage from '@rails/activestorage';
import Alpine from 'alpinejs';

window.Alpine = Alpine;

Rails.start();
ActiveStorage.start();
Alpine.start();
