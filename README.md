# Likely Thrift Compiler Bug

This repo exists to demonstrate a likely Thrift compiler bug I ran into recently.

We define the same two structs but in different order in `good.thrift` and `bad.thrift`:

## good.thrift
```
struct Child {
    1: optional string Name 
}

struct Parent {
	1: optional Child Child 
}
```

## bad.thrift
```
struct Parent {
	1: optional Child Child 
}

struct Child {
    1: optional string Name 
}
```

### **Note that:**
1. The struct definitions are identical
2. The order of their appearance in the Thrift file has been reversed
3. The `Parent` struct has a field of type `Child`

We ask thrift to generate Java from both definitions and then diff them. The diff is small but surprising:
```
diff out/good/Parent.java out/bad/Parent.java
85c85
<         new org.apache.thrift.meta_data.StructMetaData(org.apache.thrift.protocol.TType.STRUCT, Child.class)));
---
>         new org.apache.thrift.meta_data.FieldValueMetaData(org.apache.thrift.protocol.TType.STRUCT        , "Child")));
263,265d262
<     if (Child != null) {
<       Child.validate();
<     }
```

In the `bad` case, the generated `Parent.java` class:
* has incorrect metadata about its `Child` field. It is not correctly reported as `StructMetaData` but instead appears as `FieldValueMetaData` (This is how I noticed this issue: the `StructMetaData`--and the Java classname it provides--is important for a project I'm working on).
* A call to `Child.validate()` has disappeared.