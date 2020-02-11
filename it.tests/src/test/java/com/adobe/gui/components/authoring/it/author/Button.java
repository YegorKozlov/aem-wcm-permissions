package com.adobe.gui.components.authoring.it.author;

public class Button {

    private final String activator;
    private final String title;

    public Button(String title, String activator) {
        this.title = title;
        this.activator = activator;
    }

    public String title() {
        return title;
    }

    public String activator() {
        return activator;
    }
}
