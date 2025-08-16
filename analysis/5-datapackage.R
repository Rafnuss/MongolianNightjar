library(GeoLocatoR)
library(zen4R)
library(frictionless)

zenodo <- ZenodoManager$new(token = keyring::key_get(service = "ZENODO_PAT"))


## Publish Data Package
# Introduction: hhttps://raphaelnussbaumer.com/GeoPressureManual/geolocator-intro.html
# Detailed instruction: https://raphaelnussbaumer.com/GeoPressureManual/geolocator-create.html

# Create the datapackage
# pkg <- create_gldp_geopressuretemplate(".")
z <- zenodo$getDepositionByConceptDOI("10.5281/zenodo.16730669")
pkg <- zenodo_to_gldp(z)




#################
# Add data
pkg <- pkg %>% add_gldp_geopressuretemplate()


# Check package
plot(pkg)
validate_gldp(pkg)


#################
# Write datapackage

## Option 1: Manual
# https://zenodo.org/uploads/new
pkg$id <- "10.5281/zenodo.6720385"
pkg <- pkg %>% update_gldp_bibliographic_citation()

dir.create("data/datapackage", showWarnings = FALSE)
write_package(pkg, "data/datapackage/")

# Use the information in datapackage.json to fill the zenodo form.

## Option 2: API
# Create token and Zenodo manager
# https://zenodo.org/account/settings/applications/tokens/new/
keyring::key_set_with_value("ZENODO_PAT", password = "{your_zenodo_token}")
zenodo <- ZenodoManager$new(token = keyring::key_get(service = "ZENODO_PAT"))

# Create a zenodo from data package
z <- gldp_to_zenodo(pkg)

z <- zenodo$depositRecord(z, reserveDOI = TRUE, publish = FALSE)

pkg$id <- paste0("https://doi.org/", z$getConceptDOI())
pkg <- pkg %>%
  update_gldp()

for (f in list.files(pkg$version)) {
  zenodo$uploadFile(file.path(pkg$version, f), z)
}


#################
# Update metadata from Zenodo
# If you modify the metadata on zenodo, you can update your pkg with those information with

z_updated <- zenodo$getDepositionByConceptDOI("10.5281/zenodo.16730669")
pkg <- zenodo_2_gldp(z_updated, pkg)


## Make sure to submit to Zenodo community: https://zenodo.org/communities/geolocator-dp/
