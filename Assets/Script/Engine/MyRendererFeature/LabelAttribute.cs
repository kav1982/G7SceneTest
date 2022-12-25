using System;
public class LabelAttribute : Attribute
{
    public readonly string label;

    public LabelAttribute(string label)
    {
        this.label = label;
    }
}