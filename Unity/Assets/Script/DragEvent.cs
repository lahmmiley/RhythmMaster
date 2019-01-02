using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using SLua;

/*[CustomLuaClass]
public class ButtonBeginDragEvent : UnityEvent {}

[CustomLuaClass]
public class ButtonDragEvent : UnityEvent {}

[CustomLuaClass]
public class ButtonEndDragEvent : UnityEvent {}*/

[CustomLuaClass]
public class DragEvent : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    private UnityEvent m_OnBeginDrag = new UnityEvent();
    private UnityEvent m_OnDrag = new UnityEvent();
    private UnityEvent m_OnEndDrag = new UnityEvent();

    /// <summary>
    /// 开始拖动事件
    /// </summary>
    public UnityEvent onBeginDrag
    {
        get {return m_OnBeginDrag;}
        set {m_OnBeginDrag = value;}
    }

    /// <summary>
    /// 拖动ing事件
    /// </summary>
    public UnityEvent onDrag
    {
        get {return m_OnDrag;}
        set {m_OnDrag = value;}
    }

    /// <summary>
    /// 拖动结束事件
    /// </summary>
    public UnityEvent onEndDrag
    {
        get {return m_OnEndDrag;}
        set {m_OnEndDrag = value;}
    }

    public virtual void OnBeginDrag(PointerEventData eventData) {
        m_OnBeginDrag.Invoke();
    }

    public virtual void OnDrag(PointerEventData eventData) {
        m_OnDrag.Invoke();
    }

    public virtual void OnEndDrag(PointerEventData eventData) {
        m_OnEndDrag.Invoke();
    }
}
