import test from 'tape-async'
import helper from 'tipsi-appium-helper'

const { driver, elements } = helper

test('Test if user can see view', async (t) => {
  const screen = elements()

  try {
    await driver.waitForVisible(screen.title, 60000)
    const title = await driver.getText(screen.title)
    t.equal(title, 'Welcome to React Native!', 'Title is correct')
  } catch (error) {
    await helper.screenshot()
    await helper.source()

    throw error
  }
})
