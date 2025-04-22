import 'styles/application.scss';
import '../controllers';

import Rails from '@rails/ujs';
import * as ActiveStorage from '@rails/activestorage';
import Alpine from 'alpinejs';
import focus from '@alpinejs/focus'
import Tooltip from "@ryangjchandler/alpine-tooltip";

Rails.start();
ActiveStorage.start();

Alpine.plugin(Tooltip); // https://github.com/ryangjchandler/alpine-tooltip
Alpine.plugin(focus);
Alpine.start();

window.Alpine = Alpine;