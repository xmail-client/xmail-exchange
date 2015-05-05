'use strict';

var gulp   = require('gulp');
var plugins = require('gulp-load-plugins')();
var CI = process.env.CI === 'true';

var paths = {
  coffee: ['./lib/**/*.coffee'],
  watch: ['./gulpfile.js', './lib/**', './spec/**', '!spec/{temp,temp/**}'],
  tests: ['./spec/**/*.coffee', '!spec/{temp,temp/**}']
};

var plumberConf = {};

if (process.env.CI) {
  plumberConf.errorHandler = function(err) {
    throw err;
  };
}

gulp.task('lint', function () {
  return gulp.src(paths.coffee)
    .pipe(plugins.coffeelint())
    .pipe(plugins.coffeelint.reporter());
});

gulp.task('istanbul', function (cb) {
  gulp.src(paths.coffee)
    .pipe(plugins.coffeeIstanbul()) // Covering files
    .pipe(plugins.coffeeIstanbul.hookRequire()) // Force `require` to return covered files
    .on('finish', function () {
      gulp.src(paths.tests)
        .pipe(plugins.plumber(plumberConf))
        .pipe(plugins.mocha({reporter: CI ? 'spec' : 'nyan'}))
        .pipe(plugins.coffeeIstanbul.writeReports()) // Creating the reports after tests runned
        .on('finish', function() {
          process.chdir(__dirname);
          cb();
        });
    });
});

gulp.task('bump', ['test'], function () {
  var bumpType = plugins.util.env.type || 'patch'; // major.minor.patch

  return gulp.src(['./package.json'])
    .pipe(plugins.bump({ type: bumpType }))
    .pipe(gulp.dest('./'));
});

gulp.task('watch', ['test'], function () {
  gulp.watch(paths.watch, ['test']);
});

gulp.task('test', ['lint', 'istanbul']);

gulp.task('release', ['bump']);

gulp.task('dist', function () {
  return gulp.src(paths.coffee, {base: './lib'})
    .pipe(plugins.coffee({bare: true})).on('error', plugins.util.log)
    .pipe(gulp.dest('./dist'));
});

gulp.task('default', ['test', 'dist']);
