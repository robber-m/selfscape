# Inventory & Curation Module Design

This document outlines the design for a module focused on curating personal acquisitions. Users will be able to create an inventory of objects, organize them into collections, and showcase them in exhibitions with descriptive wall text.

## 1. Core Concepts & Entities

* **Acquisition (Object):** The fundamental item in the inventory.
    * Attributes:
        * `id` (unique identifier)
        * `name` (string)
        * `description` (text)
        * `images` (list of image URLs or paths)
        * `date_acquired` (date)
        * `source` (string, e.g., where it was acquired)
        * `tags` (list of strings)
        * `custom_fields` (map for user-defined attributes)
* **Collection:** A thematic grouping of Acquisitions.
    * Attributes:
        * `id` (unique identifier)
        * `name` (string)
        * `description` (text)
        * `cover_image` (optional, URL or path)
        * `acquisition_ids` (list of Acquisition IDs belonging to this collection)
* **Exhibition:** A curated presentation of Acquisitions, often with a narrative or specific layout.
    * Attributes:
        * `id` (unique identifier)
        * `title` (string)
        * `theme_description` (text, overall concept of the exhibition)
        * `opening_date` (optional, date)
        * `closing_date` (optional, date)
        * `sections` (list of Exhibition Sections, if needed for larger exhibitions)
        * `layout_details` (text or structured data describing the conceptual arrangement)
* **Exhibition Item:** Represents an Acquisition within an Exhibition, potentially with specific context.
    * Attributes:
        * `acquisition_id` (references an Acquisition)
        * `display_order` (integer)
        * `wall_text` (text, specific commentary for this item in this exhibition)
        * `section_id` (optional, if exhibition is divided into sections)
* **Wall Text:** Descriptive or interpretive text associated with an Exhibition as a whole, a section, or an individual item within an Exhibition.

## 2. Key Features & User Stories

**Acquisition Management:**
* As a user, I want to add a new acquisition to my inventory, including its name, description, images, acquisition date, and source.
* As a user, I want to view the details of a specific acquisition.
* As a user, I want to edit the details of an existing acquisition.
* As a user, I want to delete an acquisition from my inventory.
* As a user, I want to add tags to acquisitions for better organization and search.
* As a user, I want to search/filter my inventory based on name, tags, or other fields.

**Collection Management:**
* As a user, I want to create a new collection with a name and description.
* As a user, I want to add acquisitions from my inventory to a collection.
* As a user, I want to remove acquisitions from a collection.
* As a user, I want to view all acquisitions within a specific collection.
* As a user, I want to edit the details of a collection.
* As a user, I want to delete a collection.

**Exhibition Management:**
* As a user, I want to create a new exhibition with a title and theme description.
* As a user, I want to select acquisitions from my inventory or collections to include in an exhibition.
* As a user, I want to arrange the order of acquisitions within an exhibition.
* As a user, I want to write/edit wall text for the overall exhibition.
* As a user, I want to write/edit specific wall text for individual acquisitions within an exhibition.
* As a user, I want to view an exhibition, seeing the acquisitions and their associated wall text in the intended order.
* As a user, I want to edit the details of an exhibition.
* As a user, I want to delete an exhibition.
* (Future) As a user, I might want to define sections within a large exhibition.

## 3. Data Model (Conceptual Relationships)

* An **Acquisition** can exist independently.
* A **Collection** contains multiple **Acquisitions** (many-to-many relationship, often managed via a list of IDs in the Collection or a join table).
* An **Exhibition** features multiple **Exhibition Items**. Each **Exhibition Item** links to one **Acquisition**.
* An **Acquisition** can be part of multiple **Collections** and multiple **Exhibitions**.

```mermaid
erDiagram
    ACQUISITION ||--o{ EXHIBITION_ITEM : "features in"
    ACQUISITION ||--o{ COLLECTION_MEMBERSHIP : "belongs to"
    COLLECTION ||--o{ COLLECTION_MEMBERSHIP : "groups"
    EXHIBITION ||--o{ EXHIBITION_ITEM : "showcases"

    ACQUISITION {
        string id PK
        string name
        string description
        string_array images
        date date_acquired
        string source
        string_array tags
        json custom_fields
    }

    COLLECTION {
        string id PK
        string name
        string description
        string cover_image
    }

    COLLECTION_MEMBERSHIP {
        string acquisition_id FK
        string collection_id FK
    }

    EXHIBITION {
        string id PK
        string title
        string theme_description
        date opening_date
        date closing_date
        string layout_details
    }

    EXHIBITION_ITEM {
        string exhibition_id FK
        string acquisition_id FK
        int display_order
        string wall_text
        string section_id "nullable"
    }


