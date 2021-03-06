# [Models](@id ModelAPI)

More information can be found in the [Models](@ref) section of
the manual.

## Constructors

```@docs
Model
direct_model
```

## Basic functions

```@docs
backend
solver_name
Base.empty!(::Model)
mode
object_dictionary
unregister
```

## Working with attributes

```@docs
set_optimizer
optimizer_with_attributes
get_optimizer_attribute
set_optimizer_attribute
set_optimizer_attributes
set_silent
unset_silent
set_time_limit_sec
unset_time_limit_sec
time_limit_sec
```

## Copying

```@docs
ReferenceMap
copy_model
copy_extension_data
Base.copy(::AbstractModel)
```
## I/O

```@docs
write_to_file
Base.write(::IO, ::Model; ::MOI.FileFormats.FileFormat)
read_from_file
Base.read(::IO, ::Type{Model}; ::MOI.FileFormats.FileFormat)
```

## Bridge tools

```@docs
bridge_constraints
print_bridge_graph
```

## Extension tools

```@docs
operator_warn
error_if_direct_mode
```
