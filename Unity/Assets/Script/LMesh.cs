using SLua;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
using Random = UnityEngine.Random;

[CustomLuaClass]
public class LMeshEvent : UnityEvent<Rect, VertexHelper> { }

[CustomLuaClass]
public class LMesh : Graphic
{
    private float _radius;
    private float[] _valueArray = null;
    private bool _randomColor = true;
    private Color32 _color = new Color32(0, 0, 0, 0);

    protected override void OnPopulateMesh(VertexHelper vh)
    {
        vh.Clear();
        if(_valueArray != null && _valueArray.Length != 0)
        {
            Rect rect = GetPixelAdjustedRect();
            Vector3 origin = new Vector3(rect.x + rect.width * 0.5f, rect.y + rect.height * 0.5f, 100f);
            Color32 originColor;
            if(_randomColor)
            {
                originColor = new Color32((byte)Random.Range(0, 256), (byte)Random.Range(0, 256), (byte)Random.Range(0, 256), 255);
            }
            else
            {
                originColor = _color;
            }
            vh.AddVert(origin, _color, Vector2.zero);
            int segment = _valueArray.Length;
            float delta = 360 / segment;
            for(int i = 0; i < segment; i++)
            {
                float radian = Mathf.Deg2Rad * (90 + i * delta);
                float x = Mathf.Cos(radian) * _radius * _valueArray[i];
                float y = Mathf.Sin(radian) * _radius * _valueArray[i];
                Color32 color;
                if(_randomColor)
                {
                    color = new Color32((byte)Random.Range(0, 256), (byte)Random.Range(0, 256), (byte)Random.Range(0, 256), 255);
                }
                else
                {
                    color = _color;
                }
                vh.AddVert(origin + new Vector3(x, y), color, Vector2.zero);
            }

            for(int i = 0; i < (segment - 1); i++)
            {
                vh.AddTriangle(0, i + 2, i + 1);
            }
            vh.AddTriangle(0, 1, segment);
        }
    }

    public void Init(float radius)
    {
        _radius = radius;

    }

    public void SetColor(Color32 color)
    {
        _randomColor = false;
        _color = color;
    }

    public void SetData(float[] valueList)
    {
        _valueArray = valueList;
    }
}
