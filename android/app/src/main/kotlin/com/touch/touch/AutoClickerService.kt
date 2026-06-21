package com.touch.touch

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

data class ClickStep(
    val type: String, // "click" or "swipe" or "wait"
    val x: Float,
    val y: Float,
    val endX: Float = 0f,
    val endY: Float = 0f,
    val delay: Long = 1000,
    val duration: Long = 50,
    val repeat: Int = 1,
    val name: String = ""
)

object ClickManager {
    var service: AutoClickerService? = null
    var methodChannel: io.flutter.plugin.common.MethodChannel? = null
    
    var patterns: MutableList<MutableList<ClickStep>> = mutableListOf(mutableListOf())
    var activePatternIndex: Int = 0
    var randomize: Boolean = false
    
    var steps: MutableList<ClickStep>
        get() {
            if (patterns.isEmpty()) patterns.add(mutableListOf())
            if (activePatternIndex >= patterns.size) activePatternIndex = 0
            return patterns[activePatternIndex]
        }
        set(value) {
            if (patterns.isEmpty()) patterns.add(value)
            else patterns[activePatternIndex] = value
        }

    var isRunning: Boolean = false
    var loopCount: Int = 1

    fun startClicking() {
        if (isRunning) return
        isRunning = true
        service?.startExecution()
        updateStatus()
    }

    fun stopClicking() {
        if (!isRunning) return
        isRunning = false
        service?.stopExecution()
        updateStatus()
    }

    fun updateStatus() {
        Handler(Looper.getMainLooper()).post {
            methodChannel?.invokeMethod("onStatusChanged", isRunning)
        }
    }

    fun notifyStepsUpdated() {
        Handler(Looper.getMainLooper()).post {
            service?.refreshOverlayStepsList()
            
            val rootObj = JSONObject()
            rootObj.put("loopCount", loopCount)
            rootObj.put("randomize", randomize)
            rootObj.put("activePatternIndex", activePatternIndex)
            
            val patternsArray = JSONArray()
            for (pattern in patterns) {
                val stepArray = JSONArray()
                for (step in pattern) {
                    val obj = JSONObject()
                    obj.put("type", step.type)
                    obj.put("x", step.x.toDouble())
                    obj.put("y", step.y.toDouble())
                    obj.put("endX", step.endX.toDouble())
                    obj.put("endY", step.endY.toDouble())
                    obj.put("delay", step.delay)
                    obj.put("duration", step.duration)
                    obj.put("repeat", step.repeat)
                    obj.put("name", step.name)
                    stepArray.put(obj)
                }
                patternsArray.put(stepArray)
            }
            rootObj.put("patterns", patternsArray)
            
            methodChannel?.invokeMethod("onPatternsUpdated", rootObj.toString())
        }
    }

    fun updateStepsFromJson(jsonStr: String) {
        try {
            val rootObj = JSONObject(jsonStr)
            loopCount = rootObj.optInt("loopCount", 1)
            randomize = rootObj.optBoolean("randomize", false)
            activePatternIndex = rootObj.optInt("activePatternIndex", 0)
            
            patterns.clear()
            
            if (rootObj.has("patterns")) {
                val pArray = rootObj.getJSONArray("patterns")
                for (p in 0 until pArray.length()) {
                    val jsonArray = pArray.getJSONArray(p)
                    val newSteps = mutableListOf<ClickStep>()
                    for (i in 0 until jsonArray.length()) {
                        val obj = jsonArray.getJSONObject(i)
                        newSteps.add(
                            ClickStep(
                                type = obj.optString("type", "click"),
                                x = obj.getDouble("x").toFloat(),
                                y = obj.getDouble("y").toFloat(),
                                endX = obj.optDouble("endX", 0.0).toFloat(),
                                endY = obj.optDouble("endY", 0.0).toFloat(),
                                delay = obj.optLong("delay", 1000),
                                duration = obj.optLong("duration", 50),
                                repeat = obj.optInt("repeat", 1),
                                name = obj.optString("name", "")
                            )
                        )
                    }
                    patterns.add(newSteps)
                }
            } else if (rootObj.has("steps")) { // Legacy support
                val jsonArray = rootObj.getJSONArray("steps")
                val newSteps = mutableListOf<ClickStep>()
                for (i in 0 until jsonArray.length()) {
                    val obj = jsonArray.getJSONObject(i)
                    newSteps.add(
                        ClickStep(
                            type = obj.optString("type", "click"),
                            x = obj.getDouble("x").toFloat(),
                            y = obj.getDouble("y").toFloat(),
                            endX = obj.optDouble("endX", 0.0).toFloat(),
                            endY = obj.optDouble("endY", 0.0).toFloat(),
                            delay = obj.optLong("delay", 1000),
                            duration = obj.optLong("duration", 50),
                            repeat = obj.optInt("repeat", 1),
                            name = obj.optString("name", "")
                        )
                    )
                }
                patterns.add(newSteps)
            }
            
            if (patterns.isEmpty()) patterns.add(mutableListOf())
            
            Handler(Looper.getMainLooper()).post {
                service?.refreshOverlayStepsList()
            }
        } catch (e: Exception) {
            // Fallback to direct array (legacy)
            try {
                val jsonArray = JSONArray(jsonStr)
                val newSteps = mutableListOf<ClickStep>()
                for (i in 0 until jsonArray.length()) {
                    val obj = jsonArray.getJSONObject(i)
                    newSteps.add(
                        ClickStep(
                            type = obj.optString("type", "click"),
                            x = obj.getDouble("x").toFloat(),
                            y = obj.getDouble("y").toFloat(),
                            endX = obj.optDouble("endX", 0.0).toFloat(),
                            endY = obj.optDouble("endY", 0.0).toFloat(),
                            delay = obj.optLong("delay", 1000),
                            duration = obj.optLong("duration", 50),
                            repeat = obj.optInt("repeat", 1),
                            name = obj.optString("name", "")
                        )
                    )
                }
                patterns.clear()
                patterns.add(newSteps)
                activePatternIndex = 0
                Handler(Looper.getMainLooper()).post {
                    service?.refreshOverlayStepsList()
                }
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
    }
}

class AutoClickerService : AccessibilityService() {

    private var windowManager: WindowManager? = null
    private var collapsedView: View? = null
    private var configFullScreenView: View? = null
    private var collapsedParams: WindowManager.LayoutParams? = null
    private var playButtonRef: TextView? = null
    private var clickThread: Thread? = null
    private val tempPoints = mutableListOf<ClickStep>()
    private var expandedContainerRef: LinearLayout? = null

    fun refreshOverlayStepsList() {
        expandedContainerRef?.let {
            rebuildExpandedList(it)
        }
    }

    private fun rebuildExpandedList(container: LinearLayout) {
        container.removeAllViews()
        if (ClickManager.steps.isEmpty()) {
            val emptyTxt = TextView(this).apply {
                text = "No hay puntos configurados"
                setTextColor(Color.GRAY)
                textSize = 12f
                gravity = Gravity.CENTER
                setPadding(0, dpToPx(16), 0, dpToPx(16))
            }
            container.addView(emptyTxt)
            return
        }
        
        for ((index, step) in ClickManager.steps.withIndex()) {
            val stepRow = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(dpToPx(8), dpToPx(6), dpToPx(8), dpToPx(6))
                val bg = GradientDrawable().apply {
                    setColor(Color.parseColor("#1AFFFFFF"))
                    cornerRadius = dpToPx(6).toFloat()
                }
                background = bg
                val lp = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(6)
                }
                layoutParams = lp
            }
            
            // Header Row
            val headerRow = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
            }
            
            val isWait = step.type == "wait"
            val numberBadge = TextView(this).apply {
                text = if (isWait) "⏱" else "${index + 1}"
                setTextColor(Color.WHITE)
                textSize = 10f
                gravity = Gravity.CENTER
                val size = dpToPx(18)
                val mBg = GradientDrawable().apply {
                    setColor(Color.parseColor(if (isWait) "#FF00E5FF" else "#FFFF5252"))
                    shape = GradientDrawable.OVAL
                }
                background = mBg
                val lp = LinearLayout.LayoutParams(size, size).apply {
                    rightMargin = dpToPx(6)
                }
                layoutParams = lp
            }
            headerRow.addView(numberBadge)
            
            val stepTitle = TextView(this).apply {
                val defaultName = if (isWait) "Espera" else "Punto ${index + 1}"
                text = if (step.name.isNotEmpty()) step.name else defaultName
                setTextColor(Color.WHITE)
                textSize = 11f
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                val lp = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.0f)
                layoutParams = lp
            }
            headerRow.addView(stepTitle)
            
            stepRow.addView(headerRow)
            
            // Controls Row
            val controlsRow = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                val lp = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    topMargin = dpToPx(4)
                }
                layoutParams = lp
            }
            
            fun createMiniBtn(symbol: String, onClick: () -> Unit): TextView {
                return TextView(this).apply {
                    text = symbol
                    textSize = 12f
                    setTextColor(Color.parseColor("#FF00E5FF"))
                    gravity = Gravity.CENTER
                    val size = dpToPx(20)
                    val btnBg = GradientDrawable().apply {
                        setColor(Color.parseColor("#26FFFFFF"))
                        cornerRadius = dpToPx(4).toFloat()
                    }
                    background = btnBg
                    val lp = LinearLayout.LayoutParams(size, size)
                    layoutParams = lp
                    setOnClickListener {
                        onClick()
                    }
                }
            }
            
            val delayLabel = TextView(this).apply {
                text = "⏱ "
                setTextColor(Color.LTGRAY)
                textSize = 10f
            }
            controlsRow.addView(delayLabel)
            
            val delayVal = TextView(this).apply {
                text = if (step.delay >= 60000) "${(step.delay / 60000.0).toString().take(3)}m" else "${step.delay / 1000.0}s"
                setTextColor(Color.WHITE)
                textSize = 11f
                setPadding(dpToPx(4), 0, dpToPx(4), 0)
            }
            
            val minusDelay = createMiniBtn("-") {
                val diff = if (isWait) 5000L else 50L
                val newVal = (step.delay - diff).coerceAtLeast(50L)
                val updatedStep = step.copy(delay = newVal)
                ClickManager.steps[index] = updatedStep
                ClickManager.notifyStepsUpdated()
                delayVal.text = if (newVal >= 60000) "${(newVal / 60000.0).toString().take(3)}m" else "${newVal / 1000.0}s"
            }
            val plusDelay = createMiniBtn("+") {
                val diff = if (isWait) 5000L else 50L
                val newVal = step.delay + diff
                val updatedStep = step.copy(delay = newVal)
                ClickManager.steps[index] = updatedStep
                ClickManager.notifyStepsUpdated()
                delayVal.text = if (newVal >= 60000) "${(newVal / 60000.0).toString().take(3)}m" else "${newVal / 1000.0}s"
            }
            controlsRow.addView(minusDelay)
            controlsRow.addView(delayVal)
            controlsRow.addView(plusDelay)
            
            if (!isWait) {
                // Spacer
                val spacer = android.view.View(container.context)
                spacer.layoutParams = LinearLayout.LayoutParams(dpToPx(12), 1)
                controlsRow.addView(spacer)
                
                val repLabel = TextView(this).apply {
                    text = "x "
                    setTextColor(Color.LTGRAY)
                    textSize = 10f
                }
                controlsRow.addView(repLabel)
                
                val repVal = TextView(this).apply {
                    text = "${step.repeat}x"
                    setTextColor(Color.WHITE)
                    textSize = 11f
                    setPadding(dpToPx(4), 0, dpToPx(4), 0)
                }
                val minusRep = createMiniBtn("-") {
                    val newVal = (step.repeat - 1).coerceAtLeast(1)
                    val updatedStep = step.copy(repeat = newVal)
                    ClickManager.steps[index] = updatedStep
                    ClickManager.notifyStepsUpdated()
                    repVal.text = "${newVal}x"
                }
                val plusRep = createMiniBtn("+") {
                    val newVal = step.repeat + 1
                    val updatedStep = step.copy(repeat = newVal)
                    ClickManager.steps[index] = updatedStep
                    ClickManager.notifyStepsUpdated()
                    repVal.text = "${newVal}x"
                }
                controlsRow.addView(minusRep)
                controlsRow.addView(repVal)
                controlsRow.addView(plusRep)
            }
            
            stepRow.addView(controlsRow)
            container.addView(stepRow)
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // No action needed for events, we only dispatch clicks
    }

    override fun onInterrupt() {
        stopExecution()
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        ClickManager.service = this
    }

    override fun onDestroy() {
        super.onDestroy()
        ClickManager.service = null
        removeOverlay()
    }

    private fun dpToPx(dp: Int): Int {
        val density = resources.displayMetrics.density
        return (dp * density).toInt()
    }

    fun showOverlay() {
        if (collapsedView != null) return
        
        createNotificationChannel()
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, "auto_clicker_channel")
        } else {
            Notification.Builder(this)
        }
        val notification = builder
            .setContentTitle("Macro Automática Activa")
            .setContentText("El panel flotante está ejecutándose en segundo plano.")
            .setSmallIcon(android.R.drawable.ic_menu_edit)
            .build()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(1, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(1, notification)
        }
        
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        
        val windowParams = WindowManager.LayoutParams().apply {
            type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE
            format = PixelFormat.TRANSLUCENT
            flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
            width = WindowManager.LayoutParams.WRAP_CONTENT
            height = WindowManager.LayoutParams.WRAP_CONTENT
            gravity = Gravity.TOP or Gravity.START
            x = 100
            y = 100
        }
        
        collapsedParams = windowParams
        
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            val padding = dpToPx(8)
            setPadding(padding, padding, padding, padding)
            
            val bg = GradientDrawable().apply {
                setColor(Color.parseColor("#E6121214")) // Dark gray 90% opacity
                cornerRadius = dpToPx(20).toFloat()
                setStroke(dpToPx(2), Color.parseColor("#FF00E5FF")) // Cyan glow border
            }
            background = bg
        }
        
        val topBar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }
        
        // Drag handle / Logo
        val handle = TextView(this).apply {
            text = "⚡"
            textSize = 18f
            setTextColor(Color.WHITE)
            val lp = LinearLayout.LayoutParams(dpToPx(32), dpToPx(32)).apply {
                rightMargin = dpToPx(8)
            }
            this.layoutParams = lp
            gravity = Gravity.CENTER
            
            setOnTouchListener(object : View.OnTouchListener {
                private var initialX = 0
                private var initialY = 0
                private var initialTouchX = 0f
                private var initialTouchY = 0f
                
                override fun onTouch(v: View?, event: MotionEvent?): Boolean {
                    if (event == null) return false
                    when (event.action) {
                        MotionEvent.ACTION_DOWN -> {
                            initialX = windowParams.x
                            initialY = windowParams.y
                            initialTouchX = event.rawX
                            initialTouchY = event.rawY
                            return true
                        }
                        MotionEvent.ACTION_MOVE -> {
                            windowParams.x = initialX + (event.rawX - initialTouchX).toInt()
                            windowParams.y = initialY + (event.rawY - initialTouchY).toInt()
                            windowManager?.updateViewLayout(container, windowParams)
                            return true
                        }
                    }
                    return false
                }
            })
        }
        topBar.addView(handle)
        
        fun createCircleButton(symbol: String, colorHex: String, onClick: () -> Unit): TextView {
            return TextView(this).apply {
                text = symbol
                textSize = 16f
                setTextColor(Color.parseColor(colorHex))
                gravity = Gravity.CENTER
                
                val lp = LinearLayout.LayoutParams(dpToPx(36), dpToPx(36)).apply {
                    rightMargin = dpToPx(6)
                }
                this.layoutParams = lp
                
                val btnBg = GradientDrawable().apply {
                    setColor(Color.parseColor("#26FFFFFF"))
                    shape = GradientDrawable.OVAL
                }
                background = btnBg
                
                setOnClickListener {
                    onClick()
                }
            }
        }
        
        val playBtn = createCircleButton("▶", "#FF00E676") {
            if (ClickManager.isRunning) {
                ClickManager.stopClicking()
            } else {
                ClickManager.startClicking()
            }
            updateOverlayUI()
        }
        playButtonRef = playBtn
        topBar.addView(playBtn)
        
        val addBtn = createCircleButton("+", "#FF00E5FF") {
            showConfigFullScreen()
        }
        topBar.addView(addBtn)
        
        val clearBtn = createCircleButton("↺", "#FFFF5252") {
            ClickManager.steps.clear()
            ClickManager.notifyStepsUpdated()
            Toast.makeText(this@AutoClickerService, "Puntos limpiados", Toast.LENGTH_SHORT).show()
        }
        topBar.addView(clearBtn)
        
        var isExpanded = false
        val expandedScroll = android.widget.ScrollView(this)
        expandedScroll.visibility = android.view.View.GONE
        val scrollLp = LinearLayout.LayoutParams(
            dpToPx(260),
            dpToPx(220)
        )
        scrollLp.topMargin = dpToPx(8)
        expandedScroll.layoutParams = scrollLp
        
        val expandedContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
        }
        expandedScroll.addView(expandedContainer)
        expandedContainerRef = expandedContainer
        
        val editBtn = createCircleButton("☰", "#FF00E5FF") {
            isExpanded = !isExpanded
            if (isExpanded) {
                expandedScroll.visibility = android.view.View.VISIBLE
                rebuildExpandedList(expandedContainer)
                windowParams.width = dpToPx(280)
                windowParams.height = dpToPx(280)
            } else {
                expandedScroll.visibility = android.view.View.GONE
                windowParams.width = WindowManager.LayoutParams.WRAP_CONTENT
                windowParams.height = WindowManager.LayoutParams.WRAP_CONTENT
            }
            windowManager?.updateViewLayout(container, windowParams)
        }
        topBar.addView(editBtn)
        
        val closeBtn = createCircleButton("✕", "#FF9E9E9E") {
            hideOverlay()
        }
        topBar.addView(closeBtn)
        
        container.addView(topBar)
        container.addView(expandedScroll)
        
        windowManager?.addView(container, windowParams)
        collapsedView = container
        updateOverlayUI()
    }

    fun hideOverlay() {
        removeOverlay()
    }

    fun removeOverlay() {
        removeConfigFullScreen()
        collapsedView?.let {
            try {
                windowManager?.removeView(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            collapsedView = null
        }
        stopForeground(true)
    }

    fun updateOverlayUI() {
        Handler(Looper.getMainLooper()).post {
            playButtonRef?.let { btn ->
                if (ClickManager.isRunning) {
                    btn.text = "⏸"
                    btn.setTextColor(Color.parseColor("#FFFFD600"))
                } else {
                    btn.text = "▶"
                    btn.setTextColor(Color.parseColor("#FF00E676"))
                }
            }
        }
    }

    fun showConfigFullScreen() {
        if (configFullScreenView != null) return
        
        collapsedView?.visibility = View.GONE
        
        val fullParams = WindowManager.LayoutParams().apply {
            type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE
            format = PixelFormat.TRANSLUCENT
            flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            width = WindowManager.LayoutParams.MATCH_PARENT
            height = WindowManager.LayoutParams.MATCH_PARENT
        }
        
        val rootLayout = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#4D000000"))
        }
        
        tempPoints.clear()
        
        val topBar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            val pad = dpToPx(10)
            setPadding(pad, pad, pad, pad)
            
            val barBg = GradientDrawable().apply {
                setColor(Color.parseColor("#E61E1E24"))
                cornerRadius = dpToPx(8).toFloat()
            }
            background = barBg
            
            val lp = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.TOP
                topMargin = dpToPx(24)
                leftMargin = dpToPx(16)
                rightMargin = dpToPx(16)
            }
            this.layoutParams = lp
        }
        
        val title = TextView(this).apply {
            text = "Toca para añadir puntos"
            setTextColor(Color.WHITE)
            textSize = 14f
            val lp = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.0f)
            this.layoutParams = lp
        }
        topBar.addView(title)
        
        fun createActionBarBtn(textStr: String, bgHex: String, textHex: String, onClick: () -> Unit): TextView {
            return TextView(this).apply {
                text = textStr
                textSize = 12f
                setTextColor(Color.parseColor(textHex))
                val padH = dpToPx(12)
                val padV = dpToPx(6)
                setPadding(padH, padV, padH, padV)
                gravity = Gravity.CENTER
                
                val lp = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    leftMargin = dpToPx(8)
                }
                this.layoutParams = lp
                
                val btnBg = GradientDrawable().apply {
                    setColor(Color.parseColor(bgHex))
                    cornerRadius = dpToPx(6).toFloat()
                }
                background = btnBg
                
                setOnClickListener {
                    onClick()
                }
            }
        }
        
        val saveBtn = createActionBarBtn("Guardar", "#FF00E676", "#FFFFFF") {
            if (tempPoints.isNotEmpty()) {
                ClickManager.steps.addAll(tempPoints)
                ClickManager.notifyStepsUpdated()
                Toast.makeText(this, "Se añadieron ${tempPoints.size} puntos", Toast.LENGTH_SHORT).show()
            }
            removeConfigFullScreen()
        }
        
        val cancelBtn = createActionBarBtn("Cancelar", "#FFFF5252", "#FFFFFF") {
            removeConfigFullScreen()
        }
        
        topBar.addView(saveBtn)
        topBar.addView(cancelBtn)
        rootLayout.addView(topBar)
        
        var lastUpTime = 0L
        var downX = 0f
        var downY = 0f
        var downRawX = 0f
        var downRawY = 0f
        var downTime = 0L

        rootLayout.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    val x = event.x
                    val y = event.y
                    
                    val topBarCoords = IntArray(2)
                    topBar.getLocationOnScreen(topBarCoords)
                    val topBarY = topBarCoords[1]
                    val topBarHeight = topBar.height
                    
                    if (y >= topBarY && y <= topBarY + topBarHeight && x >= topBarCoords[0] && x <= topBarCoords[0] + topBar.width) {
                        return@setOnTouchListener false
                    }
                    
                    downX = x
                    downY = y
                    downRawX = event.rawX
                    downRawY = event.rawY
                    downTime = System.currentTimeMillis()
                }
                MotionEvent.ACTION_UP -> {
                    if (downTime == 0L) return@setOnTouchListener true // Ignored if started on topBar
                    
                    val upTime = System.currentTimeMillis()
                    val upRawX = event.rawX
                    val upRawY = event.rawY
                    
                    val delay = if (lastUpTime == 0L) 1000L else (downTime - lastUpTime)
                    val duration = (upTime - downTime).coerceAtLeast(50L)
                    
                    val distance = Math.hypot((upRawX - downRawX).toDouble(), (upRawY - downRawY).toDouble())
                    val isSwipe = distance > dpToPx(10)
                    
                    val stepNumber = tempPoints.size + 1
                    val newStep = ClickStep(
                        type = if (isSwipe) "swipe" else "click",
                        x = downRawX,
                        y = downRawY,
                        endX = if (isSwipe) upRawX else 0f,
                        endY = if (isSwipe) upRawY else 0f,
                        delay = delay,
                        duration = duration,
                        repeat = 1,
                        name = if (isSwipe) "Desplazamiento" else ""
                    )
                    tempPoints.add(newStep)
                    
                    val marker = TextView(this).apply {
                        text = "$stepNumber"
                        setTextColor(Color.WHITE)
                        textSize = 12f
                        gravity = Gravity.CENTER
                        
                        val size = dpToPx(30)
                        val mBg = GradientDrawable().apply {
                            setColor(Color.parseColor(if (isSwipe) "#E600E5FF" else "#E6FF5252"))
                            shape = GradientDrawable.OVAL
                            setStroke(dpToPx(1), Color.WHITE)
                        }
                        background = mBg
                        
                        val lp = FrameLayout.LayoutParams(size, size).apply {
                            gravity = Gravity.TOP or Gravity.START
                        }
                        this.layoutParams = lp
                        translationX = downX - size / 2
                        translationY = downY - size / 2
                    }
                    rootLayout.addView(marker)
                    
                    lastUpTime = upTime
                    downTime = 0L
                }
            }
            true
        }
        
        windowManager?.addView(rootLayout, fullParams)
        configFullScreenView = rootLayout
    }

    fun removeConfigFullScreen() {
        configFullScreenView?.let {
            try {
                windowManager?.removeView(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            configFullScreenView = null
        }
        collapsedView?.visibility = View.VISIBLE
    }

    fun startExecution() {
        if (ClickManager.patterns.isEmpty() || ClickManager.patterns.all { it.isEmpty() }) {
            Toast.makeText(this, "No hay patrones configurados", Toast.LENGTH_SHORT).show()
            ClickManager.isRunning = false
            ClickManager.updateStatus()
            updateOverlayUI()
            return
        }
        
        clickThread = Thread {
            try {
                var currentLoop = 0
                val totalLoops = ClickManager.loopCount
                
                while (ClickManager.isRunning && (totalLoops == 0 || currentLoop < totalLoops)) {
                    val activeList = if (ClickManager.randomize && ClickManager.patterns.isNotEmpty()) {
                        val validPatterns = ClickManager.patterns.filter { it.isNotEmpty() }
                        if (validPatterns.isNotEmpty()) validPatterns.random() else ClickManager.steps
                    } else {
                        ClickManager.steps
                    }
                    
                    for (step in activeList) {
                        if (!ClickManager.isRunning) break
                        
                        for (r in 0 until step.repeat) {
                            if (!ClickManager.isRunning) break
                            
                            val success = dispatchStep(step)
                            
                            // Jitter humano más realista: Desfase aleatorio garantizado (mínimo ±25ms + 15% del delay)
                            val baseDelay = step.delay.toLong()
                            val jitterRange = (baseDelay * 0.15).toLong() + 25L
                            val jitterMax = Math.min(jitterRange, 400L)
                            val jitter = kotlin.random.Random.nextLong(-jitterMax, jitterMax + 1L)
                            val finalDelay = Math.max(10L, baseDelay + jitter)
                            
                            Thread.sleep(finalDelay)
                        }
                    }
                    currentLoop++
                }
            } catch (e: InterruptedException) {
                // Stopped
            } finally {
                ClickManager.isRunning = false
                ClickManager.updateStatus()
                updateOverlayUI()
            }
        }
        clickThread?.start()
    }

    fun stopExecution() {
        clickThread?.interrupt()
        clickThread = null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "auto_clicker_channel",
                "Servicio de Macro",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun dispatchStep(step: ClickStep): Boolean {
        if (step.type == "wait") {
            return true
        }
        val path = Path()
        if (step.type == "swipe") {
            path.moveTo(step.x, step.y)
            path.lineTo(step.endX, step.endY)
        } else {
            // Simulamos un pulgar humano tocando rápido: dispersión de hasta ±40 píxeles
            val offsetX = kotlin.random.Random.nextInt(-40, 41).toFloat()
            val offsetY = kotlin.random.Random.nextInt(-40, 41).toFloat()
            
            // Creamos un área de toque simulando la yema del dedo (micro swipe orgánico)
            path.moveTo(step.x + offsetX, step.y + offsetY)
            path.lineTo(step.x + offsetX + kotlin.random.Random.nextInt(2, 6).toFloat(), step.y + offsetY + kotlin.random.Random.nextInt(2, 6).toFloat())
        }
        
        val gestureBuilder = GestureDescription.Builder()
        // Variación aleatoria de la duración física del toque (±15ms)
        val humanDuration = Math.max(10L, step.duration + kotlin.random.Random.nextLong(-15L, 25L))
        gestureBuilder.addStroke(GestureDescription.StrokeDescription(path, 0, humanDuration))
        
        val latch = CountDownLatch(1)
        var success = false
        
        Handler(Looper.getMainLooper()).post {
            try {
                dispatchGesture(gestureBuilder.build(), object : GestureResultCallback() {
                    override fun onCompleted(gestureDescription: GestureDescription?) {
                        success = true
                        latch.countDown()
                    }
                    override fun onCancelled(gestureDescription: GestureDescription?) {
                        success = false
                        latch.countDown()
                    }
                }, null)
            } catch (e: Exception) {
                latch.countDown()
            }
        }
        
        try {
            latch.await(step.duration + 500, TimeUnit.MILLISECONDS)
        } catch (e: InterruptedException) {
            return false
        }
        
        return success
    }
}
