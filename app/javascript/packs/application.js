import 'styles/application.scss';

import Rails from '@rails/ujs';
import * as ActiveStorage from '@rails/activestorage';
import Alpine from 'alpinejs';
import focus from '@alpinejs/focus'

window.Alpine = Alpine;

Rails.start();
ActiveStorage.start();
Alpine.plugin(focus);
Alpine.start();
