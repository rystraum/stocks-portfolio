import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

window.Stimulus = Application.start();
const context = require.context(".", true, /_controller\.js$/);
Stimulus.load(definitionsFromContext(context));
