---
title: Building AMIs
has_children: true
nav_order: 100
---

## {{ page.title }}

As noted above, mostly MDI project administrators need to build and release AWS AMIs,
this documentation is mostly for them.

However, advanced users might prefer to build their own Tier 1 or Tier 2 AMIs
instead of using the pre-built versions.  Also, tool suite developers may wish
to create and share Tier 3 AMIs carrying their specific tools and supporting resources.
These last AMIs can be made public or kept private as suits your needs.

Throughout, it is important to understand the potential risks of sharing public AMIs.
It is important that an instance be stripped of any passwords or keys that should
not be shared publicly. It is therefore important to begin with fresh instances
and to carefuly follow the instructions for how to prepare instances for public sharing
as AMIs.
