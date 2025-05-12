library(GeoLocatoR)
library(zen4R)
library(frictionless)

## Publish Data Package
# Introduction: hhttps://raphaelnussbaumer.com/GeoPressureManual/geolocator-intro.html
# Detailed instruction: https://raphaelnussbaumer.com/GeoPressureManual/geolocator-create.html

# Create the datapackage
pkg <- create_gldp_geopressuretemplate(".")

#################
# Create Metadata

# Contributors/creators:
# Default is to take the GeoPressureTemplate authors, but it is common that
# additional co-authors should be added for the datapackage
pkg$contributors <- list( # required
  list(
    title = "Raphaël Nussbaumer",
    roles = c("ContactPerson", "DataCurator", "ProjectLeader"),
    email = "raphael.nussbaumer@vogelwarte.ch",
    path = "https://orcid.org/0000-0002-8185-1020",
    organization = "Swiss Ornithological Institute"
  )
)


# Related Identifiers
# e.g. papers, project pages, derived datasets, etc.
pkg$relatedIdentifiers <- list(
  list(
    relationType = "IsSupplementTo",
    relatedIdentifier = "10.1007/s10336-022-02000-4",
    relatedIdentifierType = "DOI"
  ),
  list(
    relationType = "IsDerivedFrom",
    relatedIdentifier = "https://github.com/Rafnuss/MongolianNightjar",
    relatedIdentifierType = "URL"
  )
)

# print(pkg)




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
z <- gldp2zenodoRecord(pkg)

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

z_updated <- zenodo$getDepositionByConceptDOI(z$getConceptDOI())
pkg <- zenodoRecord2gldp(z_updated, pkg)


## Make sure to submit to Zenodo community: https://zenodo.org/communities/geolocator-dp/
