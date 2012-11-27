# GetLocalization

A simple command line tool for working with projects translated using
[Get Localization](http://www.getlocalization.com/).

## Installation

This tool is packaged as a Ruby gem, so you'll need Ruby. As of now, the gem
hasn't been released anywhere, so you need to jump through an extra hoop to
install it from GitHub. There are at least two ways:

By first grabbing the source code:

    $ git clone ...
    $ rake install

By using [specific_install](https://github.com/rdp/specific_install):

    $ gem install specific_install
    $ gem specific_install -l http://github.com/plexinc/get-localization-cli.git

The `specific_install` gem basically just does the `git clone` and `rake install`
for you and then cleans up the temp directory.

## Usage

The gem is built using Thor and is somewhat self documenting. Once it's
installed you can run `get-localization` from the root of your project and
you'll see the list of supported commands. In brief, the typical commands are:

### get-localization status

Print some information about the status of translations. This will let you know
which languages have been translated, and will warn you about languages that
have been added at the Get Localization project but haven't yet been integrated.

    $ get-localization status

    Master File: en.json => app/localizations/en.json
      da: 100.0% translated => app/localizations/da.json
      de: 100.0% translated => app/localizations/de.json
      es: 100.0% translated => app/localizations/es.json
      fr: 100.0% translated => app/localizations/fr.json
      it: 100.0% translated => app/localizations/it.json
      nl: 100.0% translated => app/localizations/nl.json
      no: 100.0% translated => app/localizations/no.json
      sv: 100.0% translated => app/localizations/sv.json
      pt-PT: 100.0% translated => app/localizations/pt.json
      fi: 100.0% translated but not defined in the YAML file
      en: 100.0% translated but not defined in the YAML file
      ru: 15.0% translated but not defined in the YAML file

### get-localization pull

Download the latest translation files. The files will be downloaded, but they
are not committed to source control, so you should look over the diffs and then
commit any changes. If there are any translations available at Get Localization
that haven't been integrated into the project yet, you'll see a warning.

    $ get-localization pull

    Processing master file en.json
    Downloading app/localizations/da.json OK
    Downloading app/localizations/de.json OK
    Downloading app/localizations/es.json OK
    Downloading app/localizations/fr.json OK
    Downloading app/localizations/it.json OK
    Downloading app/localizations/nl.json OK
    Downloading app/localizations/no.json OK
    Downloading app/localizations/sv.json OK
    Downloading app/localizations/pt.json OK
      fi: 100.0% translated but not defined in the YAML file
      en: 100.0% translated but not defined in the YAML file
      ru: 15.0% translated but not defined in the YAML file

    Latest translations have been downloaded, but not checked in. Please look over
    and commit any changes.

### get-localization push

Upload the latest master files to Get Localization.

    $ get-localization push
    Uploading en.json OK

## Project Configuration

Projects are configured using [YAML](http://www.yaml.org/). Generally speaking,
you'll run `get-localization` from the root directory of your project and put
the configuration in a `.getlocalization.yml` file in that directory. But you
can specify whatever path you'd like by using the `--project` option. A
commented example file should serve to explain the configuration options:

    ---
    # Username is optional. If unspecified, you'll be prompted.
    username: getlocalizationuser

    # Password is optional. If unspecified, you'll be prompted.
    password: somethingsecret

    # The name of the project at Get Localization
    project: myproject

    files:
      # Files is an associative array with keys corresponding to Get Localization
      # master file names.
      en.json:
        # Always specify a master key with the path to the master file.
        master: path/to/master/en.json

        # Specify whatever languages you want to include. Note that this
        # may be a subset of what's actually available. As languages are
        # sufficiently translated and validated and you'd like to include
        # them, you'll need to add the language code here along with the
        # path where it should be stored in the project. Language codes
        # must match those used by Get Localization, generally two letter
        # IANA codes.
        fr: path/to/localized/fr.json
        fr-CA: path/to/localized/fr_CA.json

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
